class Admin::AdvertController < Admin::BaseController

  def index

    @adverts =  Ecstore::Advert.paginate(:per_page=>20,:page=>params[:advert],:order=>"updated_at desc")


  end
  def new
    @adverts = Ecstore::Advert.new
    @action_url =   admin_advert_index_path
    @method = :post
  end

  def show
    @adverts  = Ecstore::Advert.find(params[:id])
    @recommend_user = session[:recommend_user]

    if @recommend_user==nil &&  params[:wechatuser]
      @recommend_user = params[:wechatuser]
    end
    if @recommend_user
      member_id =-1
      if signed_in?
        member_id = @user.member_id
      end
      now  = Time.now.to_i
      Ecstore::RecommendLog.new do |rl|
        rl.wechat_id = @recommend_user
        rl.goods_id = @good.goods_id
        rl.member_id = member_id
        rl.terminal_info = request.env['HTTP_USER_AGENT']
        #   rl.remote_ip = request.remote_ip
        rl.access_time = now
      end.save
      session[:recommend_user]=@recommend_user
      session[:recommend_time] =now
    end

  end
  def edit
    @adverts  = Ecstore::Advert.find(params[:id])
    @action_url =  admin_advert_index_path(@adverts)
    @method = :put
  end

  def create
    @adverts  = Ecstore::Advert.new params[:adverts]
    if @adverts.save
      redirect_to admin_advert_index_path
    else
      render :new
    end
  end

  def update
    @adverts  = Ecstore::Advert.find(params[:id])
    if @adverts.update_attributes(params[:adverts])
      redirect_to admin_advert_index_path
    else
      render :edit
    end
  end

  def destroy
    @adverts  = Ecstore::Advert.find(params[:id])
    @adverts.destroy
    redirect_to admin_advert_index_path
  end



end