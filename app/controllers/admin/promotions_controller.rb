class Admin::PromotionsController < Admin::BaseController
  
  def index
      promotion_type = params[:type] || "order"
  	@promotions = Ecstore::Promotion.where(:promotion_type=>promotion_type).paginate(:page=>params[:page],:per_page=>20,:order=>"mallname  desc").order("priority asc")
  end

  def new
  	@promotion = Ecstore::Promotion.new
  	@method = :post
  	@action_url = admin_promotions_path
  end

  def edit
  	@promotion = Ecstore::Promotion.find(params[:id])
  	@method = :put
  	@action_url = admin_promotion_path(@promotion)
  end


  def create
      field_name  =  params[:promotion][:field_name]

      case field_name
         when 'brand_id'
           params[:promotion].merge! :field_vals=>params[:promotion].delete(:brand_ids)
         when 'cat_id'
           params[:promotion].merge! :field_vals=>params[:promotion].delete(:cat_ids)
         when  'bn'
           params[:promotion].merge! :field_vals=>params[:promotion].delete(:bns)
         else
           params[:promotion].delete(:in_or_not)
           params[:promotion].delete(:field_name)
      end

  	@promotion = Ecstore::Promotion.new params[:promotion]
  	if @promotion.save
  		redirect_to admin_promotions_path(:type=>@promotion.promotion_type)
  	else
             params[:type] = params[:promotion][:promotion_type]
  		render :new
  	end
  end

  def update
  	@promotion = Ecstore::Promotion.find(params[:id])
      field_name  =  params[:promotion][:field_name]
      case field_name
         when 'brand_id'
           params[:promotion].merge! :field_vals=>params[:promotion].delete(:brand_ids)
         when 'cat_id'
           params[:promotion].merge! :field_vals=>params[:promotion].delete(:cat_ids)
         when  'bn'
           params[:promotion].merge! :field_vals=>params[:promotion].delete(:bns)
         else
           params[:promotion].delete(:in_or_not)
           params[:promotion].delete(:field_name)
           params[:promotion].delete(:brand_ids)
           params[:promotion].delete(:cat_ids)
           params[:promotion].delete(:bns)
      end

  	if @promotion.update_attributes(params[:promotion])
  		redirect_to admin_promotions_path(:type=>@promotion.promotion_type)
  	else
             params[:type] = params[:promotion][:promotion_type]
  		render :edit
  	end
  end

  def destroy
     @promotion = Ecstore::Promotion.find(params[:id])
     type = @promotion.promotion_type
     @promotion.destroy
     redirect_to admin_promotions_path(:type=>type)

  end

end
