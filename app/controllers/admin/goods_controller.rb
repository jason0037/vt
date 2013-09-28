#encoding:utf-8
require 'csv'
require "iconv"

module Admin
    class GoodsController < Admin::BaseController
      # skip_before_filter :require_permission!

      skip_before_filter :verify_authenticity_token,:only=>[:batch]

      
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

            @goods = Ecstore::Good.order(@order).includes(:cat,:brand,:good_type,:tegs)

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

      def update
            @good  =  Ecstore::Good.find(params[:id]) 
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

      def batch
            act = params[:act]
            goods_ids =  params[:goods_ids] || []

            conditions = { :goods_id=>goods_ids }
            # conditions = nil  if goods_ids.include?("all")

            if act == "destroy"
                Ecstore::Good.where(conditions).destroy_all
            end

            if act == "up"
                Ecstore::Good.where(conditions).update_all(:marketable=>'true',:uptime=>Time.now.to_i)
            end

            if act == "down"
                Ecstore::Good.where(conditions).update_all(:marketable=>'false',:downtime=>Time.now.to_i)
            end

            if act == "export"
                goods = Ecstore::Good.where(conditions).includes(:good_type,:brand,:cat,:products)
                file = Ecstore::Good.export(goods)
                return render :json=>{:csv=>"/tmp/goods.csv"}
                # return send_file file, :filename=>"goods_#{Time.now.strftime('%Y%m%d%H%M%S')}.csv", :type=>"text/csv"
            end

            if act=="tag"
                  tegs = params[:tegs] || {}

                  tegs.values.each  do |teg|
                        if teg[:def] == "checked"
                            Ecstore::Tagable.where(:rel_id=>goods_ids,:tag_type=>"goods",:tag_id=>teg[:tag_id]).delete_all if teg[:state] == "none"
                        end

                        if teg[:def] == "uncheck"
                            goods_ids.each do |order_id|
                                Ecstore::Tagable.create(:rel_id=>order_id,:tag_id=>teg[:tag_id],:tag_type=>"goods",:app_id=>"b2c")
                            end
                        end

                        if teg[:def] == "partcheck"
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


      def import(options={:encoding=>"GB18030:UTF-8"})
        file = params[:good][:file].tempfile
        csv_rows = CSV.read(file,options)
        @logger ||= Logger.new("log/good.log")
        # csv_rows  = CSV.parse(file_data)
        @cols = Ecstore::CvsColumn.new
        first_row = 0
        @cols.parseModel(csv_rows[first_row])
        csv_rows.shift
        @serials_num = Time.now().to_i
        @specs=[]
        @good = Ecstore::Good.new
        begin
            Ecstore::Good.transaction do
                ibn_index = @cols.index("规格货号")
                row_index = 0
                csv_rows.each do |row|
                    if row[ibn_index].nil?||row[ibn_index].empty? #规格为空的为商品
                        @good = self.save_import_cvs_goods(row,row_index)
                        if @good.nil?
                            next
                        end
                        # spec_index = @cols.index("规格")
                        spec_array = ['颜色','尺码']
                        # @specs = spec_array
                        @good_spec = spec_array
                    else
                        @specs = self.save_import_cvs_product(row,@good,@good_spec)
                    end
                    @good.spec_desc = @good.specs_desc_serialize
                    @logger.info("importing...."+@good.name)
                    @good.save!
                    row_index = row_index + 1
                end
            end
        rescue Exception => e
            @logger.error("[error]import cvs error: "+e.to_s)
            raise e
        end
        redirect_to admin_goods_path
      end

      def save_import_cvs_goods(row,index)
            bn_index = @cols.index("商品编号")
            @new_good = Ecstore::Good.find_by_bn(row[bn_index].to_i)
            if @new_good&&@new_good.persisted?
                @good = @new_good
            else
                @good = Ecstore::Good.new
            end
            @good.bn = row[bn_index].to_i
            name_index = @cols.index("商品名称")
            @good.name = row[name_index]
            # type_index = @cols.index("时装")
            # @logger ||= Logger.new("log/good.log")
            if row[0].nil?
                return
            end
            good_type = Ecstore::GoodType.find_by_name(row[0])
            sbn_index = @cols.index("供应商货号")
            if !sbn_index.blank?
                @good.sbn = row[sbn_index]
            end
            @good.type_id = good_type.type_id
            cat_index = @cols.index("分类")
            cat_arr = row[cat_index].split("->")
            cat_deep = cat_arr.length - 1
            good_cat = Ecstore::GoodCat.find_by_cat_name(cat_arr[cat_deep])
            @good.cat_id = good_cat.cat_id
            brand_index = @cols.index("品牌")
            @logger ||= Logger.new("log/good.log")
            @logger.info("brand:"+row[brand_index])
            brand = Ecstore::Brand.unscoped.find_by_brand_name(row[brand_index])
            @good.brand_id = brand.brand_id
            @good.uptime = Time.now().to_i.to_s
            @good.last_modify = Time.now().to_i.to_s
            market_index = @cols.index("上架")
            if row[market_index] == 'Y'
                @good.marketable = 'true'
            else
                @good.marketable = 'false'
            end
            desc_index = @cols.index("商品详情")
            @good.desc = row[desc_index]
            @good.save!

            tag_index = @cols.index("风格")
            tag_obj = Ecstore::TagName.find_by_tag_name(row[tag_index])
            @new_tag = Ecstore::Tag.find_by_tag_id(tag_obj.tag_id)
            if @new_tag.persisted?
                @tag = @new_tag
            else
                @tag = Ecstore::Tag.new
            end
            @tag.tag_type = 'goods'
            @tag.app_id = 'b2c'
            @tag.tag_id = tag_obj.tag_id
            @tag.rel_id = @good.goods_id
            @tag.save!
            
            keyword_index = @cols.index("商品关键字")
            Ecstore::GoodKeyword.delete_all(["goods_id = ?",@good.goods_id])
            if !row[keyword_index].blank?
                keywords_a = row[keyword_index].split("|")
                keywords_a.each do |keyword|
                    @nkw = Ecstore::GoodKeyword.where(:goods_id=>@good.goods_id,:keyword=>keyword).first
                    if @nkw&&@nkw.persisted?
                        next
                    else
                        @kw = Ecstore::GoodKeyword.new
                        @kw.goods_id = @good.goods_id
                        @kw.keyword = keyword
                        @kw.res_type = 'goods'
                        @kw.save!
                    end
                end
            end

            #新品速递相关字段
            new_index = @cols.index("商品简述")
            @good.intro = row[new_index]

            new_index = @cols.index("材质说明")
            @good.material = row[new_index]

            new_index = @cols.index("尺寸说明")
            @good.mesure = row[new_index]

            new_index = @cols.index("柔软度")
            if !row[new_index].nil?
                @good.softness = row[new_index].to_i
            end

            new_index = @cols.index("薄厚度")
            if !row[new_index].nil?
                @good.thickness = row[new_index].to_i
            end

            new_index = @cols.index("弹力度")
            if !row[new_index].nil?
                @good.elasticity = row[new_index].to_i
            end

            new_index = @cols.index("修身度")
            if !row[new_index].nil?
                @good.fitness = row[new_index].to_i
            end

            new_index = @cols.index("试穿体验说明")
            if !row[new_index].nil?
                @good.try_on = row[new_index]
            end

            new_index = @cols.index("库存")
            if !row[new_index].nil?
                @good.store = row[new_index].to_i
            end 

            return @good
      end

      def is_in_array(array,obj)
        if array.empty? 
            return false
        end
        array.each do |item|
            if item == obj
                return true
            end
        end
        return false
      end

      def save_import_cvs_product(row,good,specs)
            ibn_index = @cols.index("规格货号")
            @new_product = Ecstore::Product.find_by_bn(row[ibn_index])
            if !@new_product.nil? && @new_product.persisted?
                @product = @new_product
            else
                @product = Ecstore::Product.new
            end
            @product.goods_id = good.goods_id
            @product.bn = row[ibn_index]
            mktprice_index = @cols.index("市场价")
            @product.mktprice = row[mktprice_index]
            good.mktprice = row[mktprice_index]
            price_index = @cols.index("销售价")
            @product.price = row[price_index]
            good.price = row[price_index]
            o_index = @cols.index("定金")
            if !row[o_index].blank?
                @product.mktprice = row[mktprice_index]
                good.mktprice = row[mktprice_index]
                @product.price = row[o_index]
                good.price = row[price_index]
            end
            name_index = @cols.index("商品名称")
            @product.name = row[name_index]
            # @logger1 ||= Logger.new("log/good.log")
            # @logger1.info("------------------------a")
            # @logger1.info(@product.name)
            store_index = @cols.index("库存")
            @product.store = row[store_index]


            c_index = @cols.index("颜色")
            m_index = @cols.index("尺码")
            @spec_info = "颜色：#{row[c_index]}、尺码：#{row[m_index]}"
            specs_array = []
            specs_array.push row[c_index];
            specs_array.push row[m_index];
            private_value_array = []

            spec_value_array = []
            @spec_obj = Ecstore::SpecValue.find_by_spec_value(row[c_index])
            spec_value_array.push @spec_obj.spec_value_id if !@spec_obj.nil?
            @spec_m_obj = Ecstore::SpecValue.find_by_spec_value(row[m_index])
            spec_value_array.push @spec_m_obj.spec_value_id if !@spec_m_obj.nil?
            prd_spec_info = [row[c_index],row[m_index]]

            if !is_in_array(good.colors_a,row[c_index])
                good.colors_a.push row[c_index]
                private_value_array.push @serials_num
                spec_value = {'private_spec_value_id'=>@serials_num,'spec_value'=>row[c_index],'spec_value_id'=>@spec_obj.spec_value_id} #'spec_goods_images'=>row[img_index]
                good.colors_serialize[@serials_num]=spec_value
                @serials_num = @serials_num+1
            end

            if !is_in_array(good.sizes_a,row[m_index])
                good.sizes_a.push row[m_index]
                private_value_array.push @serials_num
                spec_value = {'private_spec_value_id'=>@serials_num,'spec_value'=>row[m_index],'spec_value_id'=>@spec_m_obj.spec_value_id} #'spec_goods_images'=>row[img_index]
                good.sizes_serialize[@serials_num]=spec_value
                @serials_num = @serials_num + 1
            end

            @prd_spec = {'spec_value'=>specs_array,'spec_private_value_id'=>private_value_array,"spec_value_id"=>spec_value_array}
            @product.last_modify = Time.now().to_i.to_s
            @product.spec_info = @spec_info
            @product.spec_desc = @prd_spec.serialize
            @product.save!
            good.save!


            spec_ids = specs.collect do |name|
                Ecstore::Spec.where(:spec_name=>name).collect do |spec|
                    Ecstore::GoodTypeSpec.where(:type_id=>good.type_id,:spec_id=>spec.spec_id).pluck(:spec_id)
                end
            end.flatten.compact
            
            Ecstore::GoodSpec.where(:product_id=>@product.product_id).delete_all
            spec_ids.each_index do |i|
                sp_val_id = Ecstore::SpecValue.where(:spec_value=>prd_spec_info[i],:spec_id=>spec_ids[i]).first.spec_value_id
                Ecstore::GoodSpec.new do |gs|
                    gs.type_id =  good.type_id
                    gs.spec_id = spec_ids[i]
                    gs.spec_value_id = sp_val_id
                    gs.goods_id = good.goods_id
                    gs.product_id = @product.product_id
                end.save

            end

            # return spec_desc
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
