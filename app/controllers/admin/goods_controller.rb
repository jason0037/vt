#encoding:utf-8
require "iconv"
require 'axlsx'

module Admin
  class GoodsController < Admin::BaseController
    # skip_before_filter :require_permission!
    skip_before_filter :verify_authenticity_token,:only=>[:batch]

    def export
      fields =  params[:fields]
      detail = Hash.new

      if(params[:batch].nil?)
        flash[:alert] = '请选择需要导出的商品'
        goods_ids =[0]
      else
        goods_ids =  params[:batch][:goods_ids] || []
      end

      ke=[]  ###规格key
      va=[]  ###规格value
      if params[:member][:select_all].to_i > 0
        #找出所有数据
        conditions = "goods_id in ("+params[:all_goods_ids]+")"
      else
        conditions = { :goods_id=>goods_ids }
      end

      # conditions = nil  if goods_ids.include?("all")
      goods = Ecstore::Good.where(conditions).includes(:good_type,:brand,:cat,:products)

      #content=Ecstore::Good.export_xls_with_pic(fields,goods) #导出excel
      package = Axlsx::Package.new
      workbook = package.workbook
      workbook.styles do |s|
        head_cell = s.add_style  :b=>true, :sz => 10, :alignment => { :horizontal => :center,
                                                                      :vertical => :center}
        goods_cell = s.add_style :b=>true,:bg_color=>"FFFACD", :sz => 10, :alignment => {:vertical => :center}
        product_cell =  s.add_style  :sz => 9

        workbook.add_worksheet(:name => "Product") do |sheet|


          goods.each do |good|
            goodsModel=good.model
            goodsCat=good.good_type.name
            goodsSize_Desc=good.size_description
            goodsSize=good.size
            goodsUnit=good.unit
            goodDesc=good.desc
            goodsBn=good.bn.to_s
            goodsCatCode= good.good_type.goods_cat_code
            goodsCatId=good.good_type.goods_cat_id
            sheet.add_row [nil ,goodsCat,goodsCatCode,goodsCatId]
            row_count=0

                good.products.each do |product|
                  unless   product.detail_spec.blank?
                    spec= JSON.parse( product.detail_spec)

                    spec.each_with_index  do |value, index|

                       ke=ke.append(value[0])

                    end end end

            sheet.add_row ["产品/规格","产品名称","产品型号","规格参数","产品规格","单位","产品简介","ERP产品编号","条码","库存数量", "交期","状态","市场价","促销价"]+ke,
                          :style=>head_cell


            row_count+=1
            #goodsSize.strip
            sheet.add_row ["产品信息",good.name,goodsModel,goodsSize_Desc,goodsSize,goodsUnit,goodDesc,goodsBn,nil,nil,"现货","上架"],:height=> 40


            # 图片
            # filename="/home/trade/pics#{good.medium_pic}"
            # if not FileTest::exist?(filename)
            #   filename = "#{Rails.root}/app/assets/images/gray_bg.png"
            # end
            # img = File.expand_path(filename)
            # sheet.add_image(:image_src => img, :noSelect => true, :noMove => true) do |image|
            #   image.width=50
            #   image.height=75
            #   image.start_at 6,  row_count
            # end



            good.products.each do |product|
              row_count +=1
              productBn = product.bn.to_s
              productBarcode=product.barcode
              productMt =product.marketable=="true" ? "Y" : "N"
              spec_values = product.spec_values.order("sdb_b2c_spec_values.spec_id asc").pluck(:spec_value).join("|")
              v =[]
              fields.each do |field|
                # if field=="进货价"
                #   v.push(product.cost)
                # end
                #
                # if field=="渠道价"
                #   v.push(product.bulk)
                # end
                # if field=="渠道零售价"
                #   v.push(product.promotion)
                # end
                # if field=="批发价"
                #   v.push(product.wholesale)
                # end
                #
                # if field=="会员价"
                #   v.push(product.price)
                # end

                if field=="市场价"
                  v.push(product.mktprice)
                end
                if field=="促销价"
                  v.push(product.promotion)
                end
              end

              unless   product.detail_spec.blank?
                spec= JSON.parse( product.detail_spec)

                spec.each_with_index  do |value, index|

                  va=va.append(value[1])

                end
              end


              sheet.add_row ["规格信息",nil,nil,nil,nil,nil,nil,productBn,productBarcode,product.store,"现货","上架",v[0],product.promotion]+va,:style=>product_cell
            end

            sheet.column_widths nil, nil,nil,nil,nil,10
          end
        end
      end

      send_data package.to_stream.read,:filename=>"goods_#{Time.now.strftime('%Y%m%d%H%M%S')}.xlsx"
      # send_data(package.to_stream.read, :type => "text/excel;charset=utf-8; header=present",:filename => "goods_#{Time.now.strftime('%Y%m%d%H%M%S')}.xls")
      #content = Ecstore::Good.export_cvs(fields,goods) #导出cvs
      # MS Office 需要转码
      # send_data(content, :type => 'text/csv',:filename => "goods_#{Time.now.strftime('%Y%m%d%H%M%S')}.csv")

      # content = Ecstore::Good.export_xls(fields,goods) #导出excel
      # send_data(content, :type => "text/excel;charset=utf-8; header=present",:filename => "goods_#{Time.now.strftime('%Y%m%d%H%M%S')}.xls")
    end

    def batch
      act = params[:act]
      goods_ids =  params[:goods_ids] || []

      conditions = { :goods_id=>goods_ids }
      # conditions = nil  if goods_ids.include?("all")

      if act == "export"
        goods = Ecstore::Good.where(conditions).includes(:good_type,:brand,:cat,:products)
        file = Ecstore::Good.exporttmp(goods)
        return render :json=>{:csv=>"/tmp/goods.csv"}
        #return send_file file, :filename=>"goods_#{Time.now.strftime('%Y%m%d%H%M%S')}.csv", :type=>"text/csv"

      end

      if act == "destroy"
        Ecstore::Good.where(conditions).destroy_all
      end

      if act == "up"
        Ecstore::Good.where(conditions).update_all(:marketable=>'true',:uptime=>Time.now.to_i)
      end

      if act == "down"
        Ecstore::Good.where(conditions).update_all(:marketable=>'false',:downtime=>Time.now.to_i)
      end

      if act=="tag"
        tegs = params[:tegs] || {}

        tegs.values.each  do |teg|
          if teg[:technicals] == "checked"
            Ecstore::Tagable.where(:rel_id=>goods_ids,:tag_type=>"goods",:tag_id=>teg[:tag_id]).delete_all if teg[:state] == "none"
          end

          if teg[:technicals] == "uncheck"
            goods_ids.each do |order_id|
              Ecstore::Tagable.create(:rel_id=>order_id,:tag_id=>teg[:tag_id],:tag_type=>"goods",:app_id=>"b2c")
            end
          end

          if teg[:technicals] == "partcheck"
            if teg[:state] == "all"
              goods_ids.each do |order_id|
                tagable = Ecstore::Tagable.where(:rel_id=>order_id,:tag_id=>teg[:tag_id],:tag_type=>"goods").first_or_initialize(:app_id=>"b2c")
                tagable.save
              end
            end

            if teg[:state] == "none"
              Ecstore::Tagable.where(:rel_id=>goods_ids,:tag_type=>"goods",:tag_id=>teg[:tag_id]).delete_all
            end
          end
        end
      end

      if act == "get_same_tags"
        tag_ids = Ecstore::Tagable.where(:rel_id=>goods_ids,:tag_type=>"goods").pluck(:tag_id)

        hash = Hash.new

        tag_ids.each do |id|
          if hash[id]
            hash[id] += 1
          else
            hash[id] = 1
          end
        end
        stat = Hash.new

        hash.each do |tag_id,count|
          if count>0 && count == goods_ids.size
            stat[tag_id] = "all"
          end

          if count > 0 && count < goods_ids.size
            stat[tag_id] = "part"
          end

          if count == 0
            stat[tag_id] = "none"
          end
        end

        return render :json=>stat
      end


      render :nothing=>true
    end

    def index
      redirect_to search_admin_goods_path(:template=>"index_goods",:view=>"index")
    end

    def select_goods
      params.delete(:action)
      params.delete(:controller)
      new_params = params.merge(:template=>"goods",:view=>"select_goods","ad[marketable]"=>"true",:layout=>"dialog")
      return redirect_to search_admin_goods_path(new_params)
    end

    def select_reco_goods
      params.delete(:action)
      params.delete(:controller)
      new_params = params.merge(:template=>"goods",:view=>"select_reco_goods","ad[marketable]"=>"true",:layout=>"dialog")
      return redirect_to search_admin_goods_path(new_params)
    end

    def select_gifts
      @gifts = Ecstore::Product.where(:goods_type=>"gift").paginate(:page=>params[:page],:per_page=>20)
      render :layout=>"dialog"
    end

    def cate_temp_download
      cat_id = params[:cat_id]

      category = Ecstore::Category.find_by_cat_id(cat_id)

      cate_specs=['产品/规格','产品名称',"产品型号","规格参数","产品规格","单位","产品简介","ERP产品编号","条码", "库存数量","交期","状态","市场价","促销价"]

      if category.type_id
        cate_type_specs = Ecstore::GoodTypeSpec.where(:type_id=>category.type_id)
        cate_type_specs.each do |spec|
          cate_specs << spec.spec.spec_name
        end
      end

      package = Axlsx::Package.new
      workbook = package.workbook
      workbook.styles do |s|
        head_cell = s.add_style  :b=>true, :sz => 10, :alignment => { :horizontal => :center,:vertical => :center}
        goods_cell = s.add_style :fg_color=>"FF0000",:bg_color=>"FFFACD", :sz => 10, :alignment => {:vertical => :center}
        product_cell =  s.add_style  :sz => 9

        workbook.add_worksheet(:name => "cate_temple#{cat_id}") do |sheet|
          sheet.add_row ["",category.cat_name,"#{category.code}","#{cat_id}"],:style=>head_cell
          sheet.add_row cate_specs,:style=>head_cell
          sheet.add_row ["产品信息"],:style=>goods_cell
          sheet.add_row ["规格信息"],:style=>product_cell
        end

      end
      send_data package.to_stream.read,:filename=>"category_template_#{cat_id}.xlsx"
    end

    def goods_cate_specs
      cat_id=params[:good][:cat]

      @category = Ecstore::Category.find_by_cat_id(cat_id)
      # if @category.type_id
      @cate_type_specs = Ecstore::GoodTypeSpec.where(:type_id=>@category.type_id)
      # end
    end

    def search
      @template =  params[:template] || "index_goods"
      @view =  params[:view] || "index"
      @layout = params[:layout] || "admin"

      marketable = params[:marketable].to_s

      if params[:order].present?
        @field, @sorter = params[:order].split("-")
        @order = "#{@field} #{@sorter}"
        @next_sorter = @sorter == "asc" ? "desc" : "asc"
      end

      @order = "goods_id desc" if @order.blank?
      vendor={'vendor_0001'=>66, 'vendor_0002'=>65,'vendor_ybpx'=>72,'vendor_xss'=>73,'vendor_xgy'=>63,'vendor_xj'=>64}
      role=current_admin.login_name.split( "_")[0]
      if (role=="vendor")
        @goods = Ecstore::Good.where(:supplier_id =>vendor[current_admin.login_name]).order(@order)
      else
        @goods = Ecstore::Good.order(@order)
      end
      #	@goods = @goods.includes(:cat,:brand,:good_type,:tegs,:supplier)

      if marketable.present?
        @goods =  @goods.where(:marketable=>marketable)
      end

      # simple search
      if params[:s].present? && params[:s][:q].present?
        q =  params[:s][:q]
        @goods = @goods.where("bn like ? or name like ?","%#{q}%","%#{q}%")
      end

      # advanced search
      if params[:ad].present?

        brand_id = params[:ad][:brand]
        cat_id = params[:ad][:cat]
        bn = params[:ad][:bn]
        price_op = params[:ad][:price_op]
        price = params[:ad][:price]
        marketable =  params[:ad][:marketable]

        # brand filter
        @goods = @goods.where(:brand_id=>brand_id) if brand_id.present?

        # cat filter
        if cat_id.present?
          cat = Ecstore::Category.find_by_cat_id(cat_id)
          cat_ids = cat.categories.collect { |cat| cat.cat_id } << cat.cat_id
          @goods = @goods.where(:cat_id=>cat_ids) if cat_ids.present?
        end

        @goods = @goods.where(:bn=>bn) if bn.present?

        # price filter
        comparison_op = case price_op
                          when "gt" then ">"
                          when "eq" then "="
                          when "lt" then "<"
                          when "ge" then ">="
                          when "le" then "<="
                          else "="
                        end
        @goods = @goods.where("price #{comparison_op} ?", price) if price.present?

        @goods = @goods.where(:marketable=>marketable.to_s) if marketable.present?
      end
      @count = @goods.count
      @goods_ids = @goods.pluck(:goods_id).join(",")
      @goods = @goods.paginate(:page=>params[:page],:per_page=>20)



      respond_to do |format|
        format.html { render @view,:layout=> @layout }
        format.js
      end
    end


    def edit
      @good =  Ecstore::Good.find(params[:id])
      @products = @good.products
      @spec_items = Ecstore::SpecItem.all
      @action_url = admin_good_path(@good)
      @method = :put
    end

    def toggle_future
      return_url =  request.env["HTTP_REFERER"]
      return_url =  admin_goods_url if return_url.blank?
      @good = Ecstore::Good.find(params[:id])
      val = @good.future == 'false' ? 'true' : 'false'
      @good.update_attribute :future, val
      redirect_to return_url
    end

    def toggle_agent
      return_url =  request.env["HTTP_REFERER"]
      return_url =  admin_goods_url if return_url.blank?
      @good = Ecstore::Good.find(params[:id])
      val = @good.agent == 'false' ? 'true' : 'false'
      @good.update_attribute :agent, val
      redirect_to return_url
    end

    def toggle_sell
      return_url =  request.env["HTTP_REFERER"]
      return_url =  admin_goods_url if return_url.blank?
      @good = Ecstore::Good.find(params[:id])
      val = @good.sell == 'false' ? 'true' : 'false'
      @good.update_attribute :sell, val
      redirect_to return_url
    end

    def spec
      @good =  Ecstore::Good.find(params[:id])
      @products = @good.products
      @spec_items = Ecstore::SpecItem.all
    end

    def add_spec_item
      @good =  Ecstore::Good.find(params[:id])
      @spec_items = Ecstore::SpecItem.all
      render :partial=>"admin/goods/spec_item",:locals=>{:item=>Ecstore::GoodSpecItem.new(:spec_value_id=>params[:spec_value_id])}
    end

    def remove_spec_item
      @good_spec_item = Ecstore::GoodSpecItem.find(params[:good_spec_item_id])
      @good_spec_item.destroy
      render :json=>{:code=>'t',:message=>'deleted successfully'}.to_json
    rescue
      render :json=>{:code=>'f',:message=>'deleted failed'}.to_json
    end

    def new
      @good  =  Ecstore::Good.new
      @action_url =  admin_goods_path
      @method = :post
    end

    def show

    end

    def create
      @good  =  Ecstore::Good.new(params[:good])
      if @good.save
        redirect_to admin_goods_url
      else
        render :new
      end

    end

    def update
      @good  =  Ecstore::Good.find(params[:id])
      @action_url = admin_good_path(@good)
      @good.update_attributes(params[:good])
      redirect_to admin_goods_url
    end

    def update_spec
      @good  =  Ecstore::Good.find(params[:id])
      params[:good_spec_items].select do |item|
        item[:spec_item_id].present?
      end.each do |good_spec_item|
        good_spec_item.merge! :spec_value_id=>params[:spec_value_id]
        good_spec_item_obj = @good.good_spec_items.where(good_spec_item.except(:min_value,:max_value,:fixed_value)).first
        if good_spec_item_obj
          good_spec_item_obj.update_attributes(good_spec_item)
        else
          @good.good_spec_items << Ecstore::GoodSpecItem.new(good_spec_item)
        end
      end
      if @good.save
        @spec_items = Ecstore::SpecItem.all
        @updated = true
        render "update"
      end
    end

    def import(options={:encoding=>"GB18030:UTF-8"})
      file = params[:good][:file].tempfile
      book = Spreadsheet.open(file)
      pp "starting import ..."
      sheet = book.worksheet(0)
      spec_id = ""

      supplier_id = 1
      goods_type_id = 1
      brand_id =1
      cat_id = 0
      
      spec_row_start = 14 #自由项开始列
      detail_spec = Hash.new
      #spec_name[0]=''
      
      @good = Ecstore::Good.new
      sheet.each_with_index do |row,i|
        if i == 0
          if row[2].nil? || row[3].nil?
            render :text=>"导入模板格式错误"
            return
          else
            cat_code = row[2]
            cat_id = row[3].to_s.strip.to_i
          end

        elsif i ==1
          #标题行，获取规格名称
          row_num = spec_row_start
          loop do
            break if row[row_num].blank?
            detail_spec["#{row[row_num]}"] =''
           # spec_name.push(row[row_num]) 
            row_num +=1
          end
        elsif row[0]=='产品信息'

          #保存goods信息---------------------------
          pp "staring...."
          if row[7].nil?
            render :text=>"第: #{i+1}个产品没有ERP产品编号"
            return
          else
            bn = row[7].to_s.strip.to_i
          end
          @new_good = Ecstore::Good.find_by_bn(bn)
          if @new_good&&@new_good.persisted?
            @good = @new_good
          else
            @good = Ecstore::Good.new
          end

          @good.bn = bn
          @good.medium_pic = "/images/a01/#{bn}_m.jpg"
          @good.big_pic = "/images/a01/#{bn}_b.jpg"
          @good.type_id = goods_type_id
          @good.supplier_id = supplier_id
          @good.brand_id = brand_id
          @good.sell = 'true'
          @good.marketable = 'true'
          #   产品/规格 产品名称  产品型号  规格参数  产品规格  单位  产品简介  ERP产品编号 条码  库存数量  交期  状态  市场价 促销价  自由项...
          if row[1].nil?
            render :text=>"第: #{i+1}个产品没有产品名称"
            return
          else
            @good.name = row[1]
          end

          if row[2].nil?
            render :text=>"第: #{i+1}个产品没有产品型号"
            return
          else
            @good.model = row[2]
          end

          @good.cat_id = cat_id
          @good.size_description = row[3]
          @good.size = row[4]
          @good.unit = row[5]
          @good.desc = row[6]

          @good.uptime=Time.now

          # spec_id = Ecstore::Spec.where(:spec_name=>row[7]).first.spec_id
          @good.save!
        elsif  row[0]=='规格信息'
          #保存 Products信息--------------------------------------------条码  库存数量  交期  状态  市场价 促销价  自由项...
          pp "here...."
          if row[7].nil?
            render :text=>"第: #{i+1}个产品没有ERP产品编号"
            return
          else
            bn = row[7]
          end
          @new_product = Ecstore::Product.find_by_bn(bn)
          if !@new_product.nil? && @new_product.persisted?
            @product = @new_product
          else
            @product = Ecstore::Product.new
            @product.bn = bn
          end

          row_num = spec_row_start
          detail_spec.keys.each do |k| 
            if !row[row_num].nil?
              detail_spec[k] = row[row_num]
            end
            row_num +=1
          end

           # @product.detail_spec = {"货叉总长度"=>row[14],"货叉总宽度"=>row[15],"货叉尺寸"=>row[16],"承重轮(双轮)"=>row[17],"承重轮(单轮)"=>row[18],"转向轮"=>row[19],"货叉最高高度"=>row[20],"货叉最低高度"=>row[21],"额定负载"=>row[22],"动力"=>row[23],"驾驶方式"=>row[24],"载荷中心距"=>row[25],"前悬距"=>row[26],"起升高度"=>row[27],"最大起升高度"=>row[28],"作业时最大高度"=>row[29],"门架倾角(前/后)"=>row[30],"标准货叉规格（长×宽）"=>row[31],"最小转弯半径"=>row[32],"最大行驶速度 前进"=>row[33],"最大行驶速度 后退"=>row[34],"最大起升速度 满载"=>row[35],"最大起升速度 空载"=>row[36],"最小通道宽度"=>row[37],"最小离地间隙"=>row[38],"最大行驶速度 (满载)"=>row[39],"最大起升速度 (满载)"=>row[40],"最大起升速度 (空载)"=>row[41],"最大下降速度 (满载)"=>row[42],"最大下降速度 (空载)"=>row[43],
           #                         "满载最大爬坡度"=>row[44],"爬坡度 (满载)"=>row[45],"爬坡度 (空载)"=>row[46],"长含货叉长"=>row[47],"长无货叉长"=>row[48],"宽"=>row[49],"门架无起升时高度"=>row[50],"护顶架高"=>row[51],"轴距"=>row[52],"轮距 前轮"=>row[53],"轮距 后轮"=>row[54],"轮胎 前轮"=>row[55],"轮胎 后轮"=>row[56],"蓄电池 电压"=>row[57],"蓄电池 容量"=>row[58],"整车全长"=>row[59],"车体长度"=>row[60],"车体宽度"=>row[61],"车体高度"=>row[62],"门架最大高度"=>row[63],"整车静态高度"=>row[64],"轮子类型（前/后）"=>row[65],"轮子数量"=>row[66],"轮轴心距"=>row[67],"转向类型（机械/液压/电子）"=>row[68],"刹车类型"=>row[69],"行走电机"=>row[70],"起升电机"=>row[71],"辅助电机"=>row[72],"货叉(长×宽×高)"=>row[73],"电压"=>row[74],"容量（铅酸蓄电池)"=>row[75],"控制器品牌"=>row[76],"控制器型号"=>row[77],"控制器规格"=>row[78],"整车重量"=>row[79],"自重 (包括蓄电池)"=>row[80],"满载时桥负荷 驱动轮侧/承重轮侧"=>row[81],"空载时桥负荷 驱动轮侧/承重轮侧"=>row[82],"轮胎(橡胶实心轮、聚氨酯轮)"=>row[83],"轮子尺寸，驱动侧"=>row[84],"轮子尺寸，承重侧"=>row[85],
           #                         "转向轮尺寸"=>row[86],"轮子数量（x=驱动轮）驱动侧/承重侧"=>row[87],"轮距，驱动侧"=>row[88],"轮距，承重侧"=>row[88],"门架缩回时高度"=>row[90],"作业时门架最大高度"=>row[91],"作业时手柄高度，最小/最大"=>row[92],"门架缩回时货叉高度"=>row[93],"总体长度"=>row[94],"货叉外宽"=>row[95],"直角堆垛通道宽度1000×1200跨货叉放置"=>row[96],"直角堆垛通道宽度800×1200跨货叉放置"=>row[97],"转弯半径"=>row[98],"行驶速度 满载/空载"=>row[99],"提升速度 满载/空载"=>row[100],"下降速度 满载/空载"=>row[101],"最大爬坡能力 满载/空载"=>row[102],"行车制动"=>row[103],"驱动电机功率"=>row[104],"提升电机功率"=>row[105],"蓄电池，根据BS(或其它)"=>row[107],"蓄电池电压/容量(5小时放电量)"=>row[108],"蓄电池重量+/-5%"=>row[109],"蓄电池规格 长x宽x高"=>row[110],"驱动控制方式"=>row[111],"驾驶员耳边噪音水平根据EN12053"=>row[112],"净重"=>row[113],"货叉轮子"=>row[114],"大轮"=>row[115],"油缸系统"=>row[116],"木箱尺寸"=>row[117],"集装箱  件/20’"=>row[118],"最大货叉高度（额定起重）"=>row[119],
           #                         "前倾/后倾"=>row[120],"总长(至货叉垂直面）"=>row[121],"宽度"=>row[122],"门架最低高度（零负载）"=>row[123],"护顶架高度"=>row[124],"最大行驶速度（零负载）"=>row[125],"起升速度（满载）"=>row[126],"总重量（零负载）"=>row[127],"前轮"=>row[128],"后轮"=>row[129],"间隙离地"=>row[130],"控制方式"=>row[131],"轮子材料"=>row[132],"操纵方式"=>row[133],"车身总宽"=>row[134],"驱动轮"=>row[135],"轮距"=>row[136],"轮子尺寸(前轮/后轮)"=>row[137],"前轮轮距"=>row[138],"车体离地高度"=>row[139],"蓄电池电压/额定容量"=>row[140],
           #                         "蓄电池尺寸(长×宽×高)"=>row[141],"货叉低放高度"=>row[142],"车轮 前轮"=>row[143],"车轮 后轮"=>row[144],"外行尺寸"=>row[145],"前移长度"=>row[146]}.to_json
          @product.detail_spec = detail_spec.to_json
          @product.barcode = row[8]
          @product.goods_id = @good.goods_id
          @product.name = @good.name
          @product.store_time = row[10]
          @product.store = row[9]
          # @product.price = row[12]
          @product.mktprice = row[12]
          @product.promotion = row[13]


          @product.save!
=begin
                #插入GoodSpec
                Ecstore::GoodSpec.where(:product_id=>@product.product_id).delete_all
                sp_val_id = Ecstore::SpecValue.where(:spec_value=>row[7],:spec_id=>spec_id).first.spec_value_id
                Ecstore::GoodSpec.new do |gs|
                    gs.type_id =  @good.type_id
                    gs.spec_id = spec_id
                    gs.spec_value_id = sp_val_id
                    gs.goods_id = @good.goods_id
                    gs.product_id = @product.product_id
                end.save
=end
        end
      end

      redirect_to admin_goods_path
    end

    def collocation
      @good = Ecstore::Good.find(params[:id])
      @collocations = @good.good_collocation.collocations if @good.good_collocation
      @goods = Ecstore::Good.where("marketable = ? and goods_id <> ? ",'true', @good.goods_id ).includes(:cat).includes(:brand).paginate(:page=>params[:page],:per_page=>20,:order => 'uptime DESC')
    end

    def set_suits
      @good = Ecstore::Good.find(params[:id])
      @good.p_50 = 'true'
      @good.save
      redirect_to admin_goods_path
    end

    def cancel_suits
      @good = Ecstore::Good.find(params[:id])
      @good.p_50 = 'false'
      @good.save
      redirect_to admin_goods_path
    end

    def create_collocation
      @good =  Ecstore::Good.find_by_goods_id(params[:collocation][:goods_id])
      if @good.good_collocation.present?
        @collocation = @good.good_collocation
        @collocation.collocations = params[:collocation][:collocations]
      else
        @collocation =  Ecstore::GoodCollocation.new params[:collocation]
      end
      if @collocation.save
        render :js=>"alert('保存成功')"
      else
        render :js=>"alert('保存失败')"
      end
    end

  end

end
