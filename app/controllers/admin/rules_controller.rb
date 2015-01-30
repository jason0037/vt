module Admin
  class RulesController < Admin::BaseController
  skip_before_filter :require_permission!
  def index
    @rules = Ecstore::Rule.paginate(:page => params[:page], :per_page => 20).order("to_time DESC")

  end

  def new
    @rules = Ecstore::Rule.new
    @method = :post
    @action_url = admin_rules_path
  end

  def create
    @rules = Ecstore::Rule.new(params[:rules]) do  |ru|
      ru.create_time=Time.now
      ru.from_time=Time.parse(params[:rules][:from_time]).to_i
      ru.to_time=Time.parse(params[:rules][:to_time]).to_i

    end
    @rules.save
    redirect_to admin_rules_url
  end
  def edit
    @rules = Ecstore::Rule.find(params[:id])
  end

  def update
    @rules = Ecstore::Rule..find(params[:id])
    if   @rules .update_attributes(params[:rules])
      redirect_to  admin_categories_url
    else
      render "edit"
    end
  end

  def show

  end








end
end
