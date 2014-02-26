#encoding:utf-8
require 'spreadsheet'
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

            if (current_admin.login_name=="vendor_0001")
              @goods = Ecstore::Good.where(:goods_id =>3465).order(@order).includes(:cat,:brand,:good_type,:tegs)
            elsif (current_admin.login_name=="vendor_0002")
              @goods = Ecstore::Good.where('goods_id<>3465').order(@order).includes(:cat,:brand,:good_type,:tegs)
            else
              @goods = Ecstore::Good.order(@order).includes(:cat,:brand,:good_type,:tegs)
            end


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
        book = Spreadsheet.open(file)
        pp "starting import ..."
        sheet = book.worksheet(0)
        spec_id = ""
        @good = Ecstore::Good.new
        sheet.each_with_index do |row,i|
            if i>4 && !row[1].blank? && !row[0].blank?
                pp "spec info ......"
                pp row[21]
                if !row[21].blank? #规格为空的为商品
                    pp "staring...."
                    @new_good = Ecstore::Good.find_by_bn(row[5].to_i)
                    if @new_good&&@new_good.persisted?
                        @good = @new_good
                    else
                        @good = Ecstore::Good.new
                    end
                    cat_arr = row[1].split("->")
                    cat_deep = cat_arr.length - 1
                    good_cat = Ecstore::GoodCat.find_by_cat_name(cat_arr[cat_deep])
                    @good.cat_id = good_cat.cat_id
                    good_type = Ecstore::GoodType.find_by_name(row[0])
                    @good.type_id = good_type.type_id
                    @good.small_pic = row[2]
                    @good.medium_pic = row[3]
                    @good.big_pic = row[4]
                    brand = Ecstore::Brand.unscoped.find_by_brand_name(row[6])
                    if !brand.blank?
                        @good.brand_id = brand.brand_id
                    end
                    @good.bn = row[5].to_i.to_s
                    @good.name = row[7]
                    @good.unit = row[9]
                    @good.price = row[19]
                    @good.mktprice = row[20]
                    @good.bulk = row[16]
                    @good.cost = row[15]
                    @good.wholesale = row[16]
                    @good.promotion=row[18]
                    @good.supplier = row[11]
                    @good.store = row[12]
                    if !row[13].blank?
                        result = Ecstore::Country.find_by_country_name(row[13])
                        if result.blank?
                            country = Ecstore::Country.new
                            country.country_name = row[13]
                            country.save
                        end
                    end
                    @good.place = row[13]
                    @good.desc = row[21]
                    @good.place_info = row[22]
                    @good.spec_info = row[23]
                    @good.intro = row[24]
                    if row[25] == "是"
                        @good.sell = 'true'
                    else
                        @good.sell = 'false'
                    end
                    if row[26] == "是"
                        @good.agent = 'true'
                    else
                        @good.agent = 'false'
                    end
                    if row[27] == "是"
                        @good.future = 'true'
                    else
                        @good.future = 'false'
                    end
                    if row[14] == "上架"
                        @good.marketable = 'true'
                    else
                        @good.marketable = 'false'
                    end
                    spec_id = Ecstore::Spec.where(:spec_name=>row[8]).first.spec_id
                    @good.save!
                else
                    pp "here...."
                    @new_product = Ecstore::Product.find_by_bn(row[5])
                    if !@new_product.nil? && @new_product.persisted?
                        @product = @new_product
                    else
                        @product = Ecstore::Product.new
                    end
                    @product.goods_id = @good.goods_id
                    @product.bn = row[5]
                    @product.name = row[7]
                    @product.store_time = row[10]
                    @product.store = row[12]
                    @product.price = row[19]
                    @product.mktprice = row[20]
                    @product.bulk = row[17]
                    @product.wholesale = row[16]
                    @product.promotion=row[18]
                    @product.save!
                    Ecstore::GoodSpec.where(:product_id=>@product.product_id).delete_all
                    sp_val_id = Ecstore::SpecValue.where(:spec_value=>row[8],:spec_id=>spec_id).first.spec_value_id
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
