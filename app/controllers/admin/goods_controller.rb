#encoding:utf-8
require "iconv"
require 'axlsx'

module Admin
    class GoodsController < Admin::BaseController
      # skip_before_filter :require_permission!
      skip_before_filter :verify_authenticity_token,:only=>[:batch]

      def export
        fields =  params[:fields]


        if(params[:batch].nil?)
          flash[:alert] = '请选择需要导出的商品'
          goods_ids =[0]
        else
          goods_ids =  params[:batch][:goods_ids] || []
        end


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

          sheet.add_row ['供应商',"类型","商品编号","规格货号","分类","品牌","图片","商品名称","上架", "规格","商品描述","库存",fields[0],fields[1],fields[2],fields[3],fields[4],fields[5]],
                        :style=>head_cell

            row_count=0

            goods.each do |good|

              supplier=good.supplier_id&&good.supplier.name
              goodsType=good.good_type&&good.good_type.name
              goodsBn=good.bn.to_s
              goodsCat=good.cat&&good.cat.full_path_name
              goodsBrand=good.brand&&good.brand.brand_name
              goodsMt =good.marketable=="true" ? "Y" : "N"
              goodsSpec =good.specs.order("sdb_b2c_specification.spec_id asc").pluck(:spec_name).join("|")
              goodsDesc=good.desc

              sheet.add_row [supplier,goodsType,goodsBn.strip,nil,goodsCat.strip,goodsBrand,nil,good.name.strip,goodsMt,goodsSpec,goodsDesc],:style=>goods_cell,:height=> 40

              row_count +=1

              filename="/home/trade/pics#{good.medium_pic}"
              if not FileTest::exist?(filename)
                filename = "#{Rails.root}/app/assets/images/gray_bg.png"
              end
              img = File.expand_path(filename)
              sheet.add_image(:image_src => img, :noSelect => true, :noMove => true) do |image|
                image.width=50
                image.height=75
                image.start_at 6,  row_count
              end

              good.products.each do |product|
                row_count +=1
                productBn = product.bn.to_s
                productMt =product.marketable=="true" ? "Y" : "N"
                spec_values = product.spec_values.order("sdb_b2c_spec_values.spec_id asc").pluck(:spec_value).join("|")
                v =[]
                fields.each do |field|
                  if field=="进货价"
                    v.push(product.cost)
                  end

                  if field=="渠道价"
                    v.push(product.bulk)
                  end
                  if field=="渠道零售价"
                    v.push(product.promotion)
                  end
                  if field=="批发价"
                    v.push(product.wholesale)
                  end

                  if field=="会员价"
                    v.push(product.price)
                  end

                  if field=="市场价"
                    v.push(product.mktprice)
                  end
                end
                sheet.add_row [nil,nil,productBn,nil,nil,nil,nil,product.name.strip, productMt,spec_values,nil,product.store,v[0],v[1],v[2],v[3],v[4],v[5]],:style=>product_cell
              end

              sheet.column_widths nil, nil,nil,nil,nil,10
            end
          end
        end

        send_data package.to_stream.read,:filename=>"goods_#{Time.now.strftime('%Y%m%d%H%M%S')}.xlsx"

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

       def select_gifts
            @gifts = Ecstore::Product.where(:goods_type=>"gift").paginate(:page=>params[:page],:per_page=>20)
            render :layout=>"dialog"
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

   def black_good
     @good =  Ecstore::BlackGood.find(params[:id])
     @action_url ="black_good_edit?id=#{params[:id]}"
   end

      def black_good_new
        @blackgood=Ecstore::BlackGood.new(params[:black_good]) do |sv|

          sv.uptime=Time.now
        #  sv.downtime=Time.parse(params[:black_good][:downtime]).to_i+(hour.to_i)*3600

        end.save



      end

   def black_good_edit
     @good =  Ecstore::BlackGood.find(params[:id])
     @good.update_attributes(params[:black_good])
     @action_url ="black_good/#{params[:id]}/edit"

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
                @spec_items = Ecorstore::SpecItem.all
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

        supplier =sheet[0,1]
        #supplierT = Ecstore::Supplier.unscoped.find_by_name(supplier)
        supplierT = Ecstore::Supplier.where(:name=>supplier).first
        if !supplierT.blank?
          supplier = supplierT.id
        else
          supplier=0
        end

        good_type = Ecstore::GoodType.find_by_name(sheet[1,1])
        @good = Ecstore::Good.new
        sheet.each_with_index do |row,i|
            #if i>4 && !row[1].blank? && !row[0].blank?
            if i>3
                pp "spec info ......"
                pp row[20]
                if row[4].nil?
                  render :text=>"Line: #{i}"
                  return
                else
                  bn = row[4].strip
                end

                if !row[0].blank? #品类为空的为商品
                    pp "staring...."
                    @new_good = Ecstore::Good.find_by_bn(bn)
                    if @new_good&&@new_good.persisted?
                        @good = @new_good
                    else
                        @good = Ecstore::Good.new
                        @good.bn = bn
                    end
                    @good.type_id = good_type.type_id
                    @good.supplier_id = supplier
                    cat_arr = row[0].split("->")
                    cat_deep = cat_arr.length - 1
                    good_cat = Ecstore::GoodCat.find_by_cat_name(cat_arr[cat_deep])
                    @good.cat_id = good_cat.cat_id

                    @good.medium_pic = row[2]
                    @good.big_pic = row[3]
                    brand = Ecstore::Brand.unscoped.find_by_brand_name(row[1])
                    if !brand.blank?
                        @good.brand_id = brand.brand_id
                    end
                    @good.name = row[6]
                    @good.unit = row[8]
                    @good.store = row[10]
                    country_name =row[11]
                    if !country_name.blank?
                      result = Ecstore::Country.find_by_country_name(country_name)
                      if result.blank?
                        country = Ecstore::Country.new
                        country.country_name = country_name
                        country.save
                      end
                    end
                    @good.uptime=Time.now
                    @good.place = row[11]
                    @good.cost = row[13]
                    @good.wholesale = row[14]
                    @good.bulk = row[15]
                    @good.promotion=row[16]
                    @good.price = row[17]
                    @good.mktprice = row[18]
                    @good.desc = row[19]
                    @good.place_info = row[20]
                    @good.spec_info = row[21]
                    #@good.intro = row[23]
                    if row[22] == "是"
                        @good.sell = 'true'
                    else
                        @good.sell = 'false'
                    end
                    if row[23] == "是"
                        @good.agent = 'true'
                    else
                        @good.agent = 'false'
                    end
                    if row[24] == "是"
                        @good.future = 'true'
                    else
                        @good.future = 'false'
                    end
                    if row[12] == "上架"
                        @good.marketable = 'true'
                    else
                        @good.marketable = 'false'
                    end
                    spec_id = Ecstore::Spec.where(:spec_name=>row[7]).first.spec_id
                    @good.save!
                else
                    pp "here...."
                    @new_product = Ecstore::Product.find_by_bn(bn)
                    if !@new_product.nil? && @new_product.persisted?
                        @product = @new_product
                    else
                        @product = Ecstore::Product.new
                        @product.bn = bn
                    end
                    @product.barcode = row[5]
                    @product.goods_id = @good.goods_id
                    @product.name = row[6]
                    @product.store_time = row[9]
                    @product.store = row[10]
                    @product.cost= row[13]
                    @product.wholesale = row[14]
                    @product.bulk = row[15]
                    @product.promotion=row[16]
                    @product.price = row[17]
                    @product.mktprice = row[18]

                    @product.save!
                    Ecstore::GoodSpec.where(:product_id=>@product.product_id).delete_all
                    sp_val_id = Ecstore::SpecValue.where(:spec_value=>row[7],:spec_id=>spec_id).first.spec_value_id
                    Ecstore::GoodSpec.new do |gs|
                        gs.type_id =  @good.type_id
                        gs.spec_id = spec_id
                        gs.spec_value_id = sp_val_id
                        gs.goods_id = @good.goods_id
                        gs.product_id = @product.product_id
                    end.save
                end
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
