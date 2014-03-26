#encoding:utf-8
require 'axlsx'

class Patch::MembersController < ApplicationController
	
	before_filter :authorize_user!
	# layout 'standard'
	layout "patch"

	before_filter do
		clear_breadcrumbs
		add_breadcrumb("我的贸威",:member_path)
	end


	def show
		@orders = @user.orders.limit(5)
		@unpay_count = @user.orders.where(:pay_status=>'0',:status=>'active').size
		add_breadcrumb("我的贸威")
	end

	def orders
		@orders = @user.orders.paginate(:page=>params[:page],:per_page=>10)
		add_breadcrumb("我的订单")
	end

	def coupons
		@user_coupons = @user.user_coupons.paginate(:page=>params[:page],:per_page=>10)
		add_breadcrumb("我的优惠券")
  end


  def goods
    @orders = @user.orders.joins(:order_items).where('sdb_b2c_order_items.storaged is null').paginate(:page=>params[:page],:per_page=>10)
    add_breadcrumb("我的商品")
  end

  def inventorys
    @inventorys = @user.inventorys.paginate(:page=>params[:page],:per_page=>10)
    add_breadcrumb("我的库存")
  end

  def inventorylog
    @inventorylog = @user.inventory_log.order("createtime desc").paginate(:page=>params[:page],:per_page=>10)
    add_breadcrumb("出入库记录")
  end

  def export_inventory
    #以后会加入时间区段限制条件
    conditions = { :member_id=>current_account }
    inventorylog = Ecstore::InventoryLog.where(conditions)
    package = Axlsx::Package.new
    workbook = package.workbook
    workbook.styles do |s|
      head_cell = s.add_style  :b=>true, :sz => 10, :alignment => { :horizontal => :center,
                                                                    :vertical => :center}
      product_cell =  s.add_style  :sz => 9, :alignment => {:vertical => :top}

      workbook.add_worksheet(:name => 'Product') do |sheet|

        sheet.add_row ['出/入库','产品编号','条形码','图片','商品名称','价格' ,'出入库数量', '出入库时间'] ,:style=>head_cell

        row_count=0

        inventorylog.each do |log|

          in_or_out =log.in_or_out== "\1"  ? '入库' : '出库'
          createtime =Time.at(log.createtime).to_s
#log.quantity.to_s,log.product_id.quantity.to_s,
          sheet.add_row [in_or_out,log.bn,log.barcode.to_s,nil,log.name,log.price,log.quantity,createtime] ,
                        :style=>product_cell,:height=>50

          row_count +=1

          filename="/home/trade/pics#{log.good.medium_pic}"
          if not FileTest::exist?(filename)
            filename = "#{Rails.root}/app/assets/images/gray_bg.png"
          end
          img = File.expand_path(filename)
          sheet.add_image(:image_src => img, :noSelect => true, :noMove => true) do |image|
            image.width=50
            image.height=80
            image.start_at 3,  row_count
          end

          sheet.column_widths nil, nil,nil,10
        end
      end
    end

    send_data package.to_stream.read,:filename=>"inventory_#{Time.now.strftime('%Y%m%d%H%M%S')}.xlsx"
  end

	def advance
		@advances = @user.member_advances.paginate(:page=>params[:page],:per_page=>10)
		add_breadcrumb("我的预存款")
	end
	
	def favorites
		@favorites = @user.favorites.includes(:good).paginate(:page=>params[:page],:per_page=>10,:order=>"create_time desc")
		add_breadcrumb("我的收藏")
	end
	
end
