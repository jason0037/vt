class Admin::StaticPagesController < Admin::BaseController

	def index

		@pages =  Ecstore::Page.paginate(:per_page=>20,:page=>params[:page],:order=>"updated_at desc")

      if cookies["MEMBER"]
        @supplier = Ecstore::Supplier.where(:member_id=>cookies["MEMBER"].split("-").first,:status=>1).first
        @pages = @pages.where(:supplier_id=>@supplier.id).paginate(:per_page=>20,:page=>params[:page],:order=>"updated_at desc")

      end
  end

	def new
		@page  = Ecstore::Page.new
		@action_url =  admin_static_pages_path
		@method = :post
	end

	def show
		@page  = Ecstore::Page.find(params[:id])
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
		@page  = Ecstore::Page.find(params[:id])
		@action_url =  admin_static_page_path(@page)
		@method = :put
	end

	def create
		@page  = Ecstore::Page.new params[:page]
		if @page.save
			redirect_to admin_static_pages_url
		else
			render :new
		end
	end

	def update
		@page  = Ecstore::Page.find(params[:id])
		if @page.update_attributes(params[:page])
			redirect_to admin_static_pages_url
		else
			render :edit
		end
	end

	def destroy
		@page  = Ecstore::Page.find(params[:id])
		@page.destroy
		redirect_to admin_static_pages_url
	end
end
