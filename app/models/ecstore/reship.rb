#encoding:utf-8
class Ecstore::Reship < Ecstore::Base
	self.table_name = 'sdb_b2c_reship'
	self.accessible_all_columns

	has_many :reship_items, :foreign_key=>"reship_id"

	belongs_to :order, :foreign_key=>"order_id"

	attr_accessible :reship_items, :province, :city, :district
	def reship_items=(items)
		items.each do |item|
			obj = Ecstore::ReshipItem.new(item)
			self.reship_items << obj if obj.number > 0
		end
	end


	include Ecstore::AddressFields
	before_save :make_area
	validates_presence_of :logi_id,:message=>"必须填写物流公司"
	validates_presence_of :ship_name,:message=>"必须填写收货人"
	
	validates_presence_of :ship_addr,:message=>"必须填写收货地址"

	validates :ship_mobile, presence: { presence: true, message: "必须填写手机号码" },
	                                      format: { with: /^\d{11}$/, message: "手机号码必须是11位数字" }
	validate :check_area
      def check_area
      		if province.blank? || city.blank?
      		    self.errors.add(:ship_area, "请选择送货地区")
      		else
      			if Ecstore::Region.find_by_region_id(city).subregions.size > 0
      				self.errors.add(:ship_area, "请选择送货地区") if district.blank?
      			end
      		end
      end



	before_create :set_reship_id
	
	def set_reship_id
		self.reship_id = self.class.generate_reship_id
	end

	def self.generate_reship_id
	    _time = "9#{Time.now.strftime('%Y%m%d%H%M%S')}"
	    seq = rand(10000)
          loop do
          	  _reship_id = "#{_time}#{seq}"
              return _reship_id  unless Ecstore::Reship.find_by_reship_id(_reship_id)
              seq = 1 if seq == 9999
              seq += 1
          end
	end


	after_save :update_order

	def update_order

		#  update order ship_status
		reship_ids = Ecstore::Reship.where(:order_id=>self.order_id).pluck(:reship_id)
		reship_total = Ecstore::ReshipItem.where(:reship_id=>reship_ids).sum("number")
		order_total = Ecstore::OrderItem.where(:order_id=>self.order_id).sum("nums")


		op = Ecstore::Account.find_by_login_name(self.op_name)
		order_log = Ecstore::OrderLog.new do |order_log|
			order_log.rel_id = self.order_id
			order_log.op_id = op.account_id
			order_log.op_name = self.op_name
			order_log.alttime = self.t_begin
			order_log.behavior = 'reship'
			order_log.result = "SUCCESS"
		end

		# 部分退货 
		if reship_total > 0 && reship_total < order_total
			self.order.update_attribute :ship_status, '3'
			order_log.log_text = {:txt_key=>"部分商品退货 ! ",:reship_id=>self.reship_id}.serialize
			order_log.save
		end

		# 全部退货
		if reship_total > 0 && reship_total == order_total
			self.order.update_attribute :ship_status, '4'
			order_log.log_text = {:txt_key=>"商品已退货 ! ",:reship_id=>self.reship_id}.serialize
			order_log.save
		end

		# 更新商品库存
		self.reship_items.each do |reship_item|
			_product  = reship_item.product
			if _product
				_product.update_attribute :store, _product.store + reship_item.number
				_product.update_attribute :freez, _product.freez - reship_item.number
			end
		end

	end

end