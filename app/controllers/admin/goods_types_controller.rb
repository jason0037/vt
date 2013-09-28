#encoding:utf-8
class Admin::GoodsTypesController < Admin::BaseController
  # GET /admin/cards
  # GET /admin/cards.json
  def index
    @types = Ecstore::GoodType.paginate(:page=>params[:page],:per_page=>20)
  end

  def edit
    @goodtype = Ecstore::GoodType.find(params[:id])
    @specs = Ecstore::GoodTypeSpec.where(:type_id=>@goodtype.type_id)
    @spec_ids = []
    @specs.each do |spec|
      @spec_ids << spec.spec_id
    end
  end

  def create
      @goodtype = Ecstore::GoodType.new
      @goodtype.name = params[:goods_type][:name]
      @goodtype.is_physical = 1
      @goodtype.schema_id = "custom"
      @use_brand = "0"
      @use_props = "0"
      if params[:goods_type][:use_brand]
        @use_brand = "1"
      else
        @use_brand = "0"
      end
      if params[:goods_type][:use_props]
        @use_props = "1"
      else
        @use_brand = "0"
      end
      @setting = {'use_brand'=>@use_brand,'use_props'=>@use_props}
      @goodtype.setting = @setting.serialize
      @goodtype.save

      params[:goods_type][:spec].each do |spec|
        if spec !=""
          @GoodTypeSpec = Ecstore::GoodTypeSpec.new
          @GoodTypeSpec.type_id = @goodtype.type_id
          @GoodTypeSpec.spec_id = spec
          @GoodTypeSpec.spec_style = "flat"
          @GoodTypeSpec.save
        end
      end

      redirect_to admin_goods_types_path
  end

  def updateType
    @goodtype = Ecstore::GoodType.find(params[:id])
    @goodtype.name = params[:ecstore_good_type][:name]
    Ecstore::GoodTypeSpec.where(:type_id=>params[:id]).delete_all
    params[:ecstore_good_type][:spec].each do |spec|
        if spec !=""
          @GoodTypeSpec = Ecstore::GoodTypeSpec.new
          @GoodTypeSpec.type_id = @goodtype.type_id
          @GoodTypeSpec.spec_id = spec
          @GoodTypeSpec.spec_style = "flat"
          @GoodTypeSpec.save
        end
    end
    @goodtype.save
    redirect_to admin_goods_types_path
  end

  def destroy
    @goodtype = Ecstore::GoodType.find(params[:id])
    @goodtype.destroy
    redirect_to admin_goods_types_path
  end
end
