#encoding:utf-8
class Admin::SpecItemsController < Admin::BaseController
  layout 'dialog'

  def index
  	@spec_items = Ecstore::SpecItem.all
  end

  def new
  	@title = "新建可选规格"
  	@spec_item =  Ecstore::SpecItem.new(:item_type=>"scope")
  end

  def edit
  	@title = "编辑可选规格"
  	@spec_item = Ecstore::SpecItem.find(params[:id])
  end

  def create
  	@spec_item =  Ecstore::SpecItem.new(params[:spec_item])
  	if @spec_item.save
  		redirect_to admin_spec_items_url
  	else
  		render :new
  	end
  end

  def update
  	@spec_item = Ecstore::SpecItem.find(params[:id])
  	if @spec_item.update_attributes(params[:spec_item])
  		redirect_to admin_spec_items_url
  	else
  		render :edit
  	end
  end

  def destroy
  	@spec_item = Ecstore::SpecItem.find(params[:id])
  	@spec_item.destroy
  	redirect_to admin_spec_items_url
  end

end
