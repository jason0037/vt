#encoding:utf-8
require 'csv'
class Ecstore::Order < Ecstore::Base

  self.table_name = "sdb_b2c_orders"
  has_many :order_dining , :foreign_key=>"order_id"
  has_many  :order_items, :foreign_key=>"order_id"
  has_many :order_pmts, :foreign_key=>"order_id"
  has_many :order_logs,:foreign_key=>"rel_id"
  has_many :deliveries, :foreign_key=>"order_id"

  belongs_to :shop,:foreign_key=>"order_id"
  belongs_to :manager,:foreign_key=>"desktop_user_id"
  belongs_to :user,:foreign_key=>"member_id"
  belongs_to :wechat_follower, :foreign_key=>"recommend_user"

  self.accessible_all_columns

  attr_accessor :ship_day,:ship_special,:ship_time2
  attr_accessible :order_id,:ship_day,:serverbill,:serverinvoice,:serverwarehouse,:ship_special,:from_addr, :ship_time2, :coupon, :coupon_no,:province,:city,:district,:weight,:recommend_user

  include Ecstore::AddressFields

  has_many :bills, :foreign_key=>"rel_id", :conditions=> { :pay_object=> "order" }

  has_many :payments, :through=>:bills

  has_many :refunds, :through=>:bills

  has_one :aftersale, :foreign_key=>"order_id"

  has_many :tagables, :foreign_key=>"rel_id"
  has_many :tegs, :through=>:tagables

  has_many :reships, :foreign_key=>"order_id"


  before_create :initialize_attrs

  def initialize_attrs
    self.order_id = Ecstore::Order.generate_order_id
    # self.total_amount = 1
    # self.final_amount = 1
    self.createtime = self.last_modified = Time.now.to_i
    self.status = "active"
    self.cost_item = 0
    self.discount = 0
    self.currency = "CNY"

    if self.ship_day == 'special'
      self.ship_time = "#{self.ship_special}#{self.ship_time2}"
    else
      self.ship_time = "#{self.ship_day}#{self.ship_time2}"
    end

  end

  def shipping
    return "快递" if self.shipping_id==1
    return "自提" if self.shipping_id==0
  end

  before_create :calculate_order_amount,:calculate_share

  def calculate_order_amount
    # =====order amount ====
    items_amount = self.order_items.select{ |order_item| order_item.item_type == 'product' }.collect{ |order_item|  order_item.amount }.inject(:+).to_f

    # =====pmts  amount====
    pmts_amount = self.order_pmts.collect { |order_pmt| order_pmt.pmt_amount }.inject(:+).to_f

    #=========freigh ammount========
    #German Sausage
    freight77 =0
    items_amount_supplier = self.order_items.select{ |order_item| order_item.good.supplier_id == 77}.collect{ |order_item|  order_item.amount }.inject(:+)
    if items_amount_supplier
      if items_amount_supplier <380
        freight77 = 35
      end
    end
    #Weiss
    freight127 =0
    items_amount_supplier = self.order_items.select{ |order_item| order_item.good.supplier_id == 127}.collect{ |order_item|  order_item.amount }.inject(:+)
    if items_amount_supplier
      if items_amount_supplier <200
        freight127 = 30
      end
    end
    #诺狮
    freight97 = 0
    items_amount_supplier = self.order_items.select{ |order_item| order_item.good.supplier_id == 97}.collect{ |order_item|  order_item.amount }.inject(:+)
    if items_amount_supplier
      if items_amount_supplier <60
        freight97 = 10
      end
    end
=begin
#天山蟹客
          items_amount_supplier = self.order_items.select{ |order_item| order_item.good.supplier_id == 87}.size
          if items_amount_supplier >0
            freight += 0
          end
#万家物流
         items_amount_supplier = self.order_items.select{ |order_item| order_item.good.supplier_id == 98}.size
         if items_amount_supplier >0
           freight += 0
         end
#金芭浪
         items_amount_supplier = self.order_items.select{ |order_item| order_item.good.supplier_id == 99}.size
         if items_amount_supplier >0
           freight += 0
         end
=end
    self.cost_freight =  freight77 + freight97 + freight127
    # items_amount = self.order_items.select{ |order_item| order_item.item_type == 'product' }.collect{ |order_item|  order_item.amount }.inject(:+).to_f

    if  items_amount&&pmts_amount
      self.final_amount = self.total_amount  =  items_amount - pmts_amount + self.cost_freight
    else
    end
  end

  def calculate_share
    share_for_promotion = self.order_items.select{ |order_item| order_item.item_type == 'product' }.collect{ |order_item|  order_item.share_for_promotion}.inject(:+).to_f
    share_for_sale = self.order_items.select{ |order_item| order_item.item_type == 'product' }.collect{ |order_item|  order_item.share_for_sale}.inject(:+).to_f
    share_for_shop = self.order_items.select{ |order_item| order_item.item_type == 'product' }.collect{ |order_item|  order_item.share_for_shop}.inject(:+).to_f
    self.share_for_promotion = share_for_promotion
    self.share_for_shop = share_for_shop
    self.share_for_sale = share_for_sale
  end

  before_save :calculate_itemnum

  def calculate_itemnum
    self.itemnum = self.order_items.collect{ |order_item| order_item.nums }.inject(:+)
  end

  after_create :update_user_coupon, :update_advance

  def update_user_coupon
    codes = self.order_pmts.where(:pmt_type=>"coupon").collect { |p| p.coupon_code }
    codes.each do |code|
      coupon = Ecstore::NewCoupon.check_and_find_by_code(code)
      user_coupon = Ecstore::UserCoupon.where(:member_id=>self.member_id,
                                              :coupon_code=>code,
                                              :coupon_id=>coupon.id).first_or_create
      user_coupon.increment!(:used_times)
      user_coupon.touch(:used_at)
    end
  end

  def update_advance
    if self.part_pay?
      advance = self.user.advance
      advance_freeze = self.user.advance_freeze
      Ecstore::User.where(:member_id => self.member_id).update_all( { :advance=>(advance - self.part_pay), :advance_freeze=>(advance_freeze + self.part_pay)} )
    end
  end



  around_update :finish_order

  def finish_order

    before_update_status = self.class.find_by_order_id(self.order_id).status
    yield
    after_update_status = self.status

    # 完成订单
    if before_update_status != 'finish' && after_update_status == 'finish'

      _order = self
      _user = self.user

      if %w(0 1 2).include?(self.ship_status)
        # coupon promotions
        order_pmts = _order.order_pmts.where(:pmt_type=>%w(goods order))
        order_pmts.each do |order_pmt|
          pmt = order_pmt.promotion
          if pmt&&pmt.action_type == 'coupon'
            (pmt.action_val||[]).each do |coupon_id|
              coupon = Ecstore::NewCoupon.find_by_id(coupon_id)
              Ecstore::UserCoupon.create({
                                             :member_id => _user.member_id,
                                             :coupon_id=>coupon_id,
                                             :coupon_code=> coupon.generate_coupon_code(true)
                                         })
            end
          end
        end
      end

      if _order.part_pay?
        advance = _user.advance
        advance_freeze = _user.advance_freeze

        if %w(0 1 2).include?(self.ship_status)  # 发货时更新冻结预存款
          Ecstore::User.where(:member_id=>_user.member_id).update_all({ :advance_freeze=> advance_freeze - self.part_pay })
        else # 退货时更新冻结预存款和预存款
          Ecstore::User.where(:member_id=>_user.member_id).update_all({ :advance_freeze=> advance_freeze - self.part_pay,:advance=>advance + self.part_pay })
        end
      end

    end

    # 作废订单
    if before_update_status != 'finish' && after_update_status == 'dead'
      # 已发货或者部分发货订单恢复库存
      if %w(1 2).include?(self.ship_status)
        self.order_items.each do |order_item|
          if (_product = order_item.product) && order_item.sendnum > 0
            _product.update_attribute :freez, _product.freez - order_item.sendnum
            _product.update_attribute :store, _product.store + order_item.sendnum
          end
        end
      end
      # 已付款或部分付款恢复预存款
      if %w(1 3).include?(self.pay_status) && self.part_pay?
        advance = self.user.advance
        advance_freeze =  self.user.advance_freeze
        Ecstore::User.where(:member_id=>self.member_id).update_all({ :advance_freeze=> advance_freeze - self.part_pay, :advance=>advance +  self.part_pay })
      end

    end


  end


  def self.generate_order_id
    seq = rand(0..9999)
    loop do
      seq = 1 if seq == 9999
      _order_id = Time.now.strftime("%Y%m%d%H") + ( "%04d" % seq.to_s )
      return _order_id unless  Ecstore::Order.find_by_order_id(_order_id)
      seq += 1
    end
  end

  def pay_amount
    final_pay
  end

  def part_pay?
    self.part_pay > 0
  end


  def products_total
    self.order_items.select{ |order_item| order_item.item_type == 'product' }.collect{ |order_item|  order_item.amount }.inject(:+).to_f
  end

  def pmts_total
    self.order_pmts.collect { |order_pmt| order_pmt.pmt_amount }.inject(:+).to_f
  end

  def final_pay
    products_total + cost_freight - pmts_total - part_pay.to_f - bcom_discount
  end

  def bcom_discount
    return (products_total - pmts_total) - ((products_total - pmts_total) * 0.95).to_f if payment == 'bcom'
    0
  end



  def created_at
    Time.at(self.createtime).strftime("%Y-%m-%d %H:%M:%S") if self.createtime
  end

  def payment_name
    return "账期" if payment == "term"
    return "微信支付" if payment == "wxpay"
    return "支付宝手机版" if payment == "alipaywap"    
    return "支付宝PC版" if payment == "alipay"
    return "环迅人民币支付" if payment == "ips"
    return "交通银行网上支付" if payment == "bcom"
    return "工商银行网上支付" if payment == "icbc"
    return "预存款在线支付" if payment == "deposit"
    return "货到付款" if payment == "offline"
    return "快钱在线支付" if payment == "99bill"
    return "无支付方式" if payment.blank?
  end

  def status_text
      return '活动订单 ' if status == 'active'
    return '已作废' if status == 'dead'
    return '已完成' if status == 'finish'
  end
  #serverinvoice 发票信息 0：没有发票 ，1： 运费发票(按照总运费的11%收取) 2： 服务费发票 (按照总运费的8%收取) 3：  自带发票（按照总运费的1%）
  #进仓服务费 0 没有，1：（150元/票)
  #serverbill 签单返回 0：没有 1：5元

  def serverinvoice_text
       return  '未选择发票' if serverinvoice=='0'
       return  '运费发票(总运费的11%)' if serverinvoice=='1'
       return  '服务费发票 (总运费的8%)' if serverinvoice=='2'
       return  '自带发票(总运费的1%)' if serverinvoice=='3'
   end

  def serverbill_text
    return  '未选择签单返回' if serverbill=='0'
    return  '5元/票(签单返回)' if serverbill=='1'
  end

  def serverwarehouse_text
    return  '未选择进仓' if serverwarehouse=='0'
    return  '进仓服务费（150元/票)' if serverwarehouse=='1'
  end

  def pay_status_text
    return '未付款' if pay_status == '0'
    return '已付款' if pay_status == '1'
    return '付款至担保方' if pay_status == '2'
    return '部分付款' if pay_status == '3'
    return '部分退款' if pay_status == '4'
    return '已退款' if pay_status == '5'
  end

  def ship_status_text
    return '未发货'  if ship_status == '0'
    return '已发货' if ship_status == '1'
    return '部分发货' if ship_status == '2'
    return '部分退货' if ship_status == '3'
    return '已退货' if ship_status == '4'
  end

  def order_status_text
    return '已作废'  if status =='dead'
    return '已完成'  if status =='finish'
    return '已发货'  if status == 'active' && ship_status == '1'
    return '已付款'  if status == 'active' && pay_status == '1'
    return '待付款'  if status == 'active' && pay_status == '0'
  end

  def progress_status
    return 'finish'  if status == 'finish'
    return 'dead' if status == 'dead'
    return 'shipping'  if ship_status == '1'
    return 'paid' if payment == 'offline'
    return 'paid'  if  pay_status == '1'
    return 'active'  if status == 'active'
    nil
  end

  def pay_type
    return 'offline' if self.payment == "offline"
    return 'deposit' if self.payment == 'deposit'
    return nil  if self.payment.blank?
    return "online"
  end


  def finished_at
    log = self.order_logs.where(:behavior=>'finish',:result=>"SUCCESS").first
    Time.at(log.alttime).strftime("%Y-%m-%d %H:%M:%S") if log
  end


  def paid_amount
    payments.where(:status=>"succ").sum(:money)
  end

  def refunded_amount
    refunds.where(:status=>"succ").sum(:money)
  end


  def self.export(orders=[],file="#{Rails.root}/public/tmp/orders.csv")

    CSV.open(file,"w:GB18030") do |csv|
      csv << [ "订单号(order_id)",
               "订单总额(final_amount)",
               "付款状态(pay_status)",
               "发货状态(ship_status)",
               "下单时间(createtime)",
               "支付方式(payment)",
               "会员用户名(member_id)",
               "订单状态(status)",
               "收货地区(ship_area)",
               "收货人(ship_name)",
               "收货地址(ship_addr)",
               "收货人电话(ship_tel)",
               "收货人手机(ship_mobile)"
      ]
      orders.each do |order|
        csv << [ order.order_id,
                 order.final_amount,
                 order.pay_status_text,
                 order.ship_status_text,
                 order.created_at,
                 order.payment_name,
                 order.user.login_name,
                 order.order_status_text,
                 order.ship_area,
                 order.ship_name,
                 order.ship_addr,
                 order.ship_tel,
                 order.ship_mobile
        ]
      end
    end

    file

  end

end