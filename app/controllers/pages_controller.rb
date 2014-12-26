class PagesController < ApplicationController

	layout 'page_cheuks'

  before_filter do
    clear_breadcrumbs
    add_breadcrumb("我的卓展",:member_path)
  end


	def show
		@page = Ecstore::Page.includes(:meta_seo).find(params[:id])
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
        #rl.goods_id = @good.goods_id
        rl.member_id = member_id
        rl.terminal_info = request.env['HTTP_USER_AGENT']
        #   rl.remote_ip = request.remote_ip
        rl.access_time = now
      end.save
      session[:recommend_user]=@recommend_user
      session[:recommend_time] =now
    end

    if @page.supplier_id
      supplier_id = @page.supplier_id
    elsif params[:supplier_id]
      supplier_id = params[:supplier_id]
    end
      @menu=nil
    clear_breadcrumbs

    if @page.category=="services"
      @menu="services"
      add_breadcrumb("服务中心",:member_path)
    else @page.category=="techaical"
    @menu="techaical"
    add_breadcrumb("技术中心",:member_path)
    end
    add_breadcrumb("#{@page.title}")
    if supplier_id
      @supplier = Ecstore::Supplier.find(supplier_id)
       return render :layout=>@supplier.layout
    elsif params[:platform] =='vshop'
      render :layout=>'vshop'
    elsif params[:platfom]=='mobile'
      render :layout=>'mobile_new'
    else

      render :layout=> "page_cheuks"
    end

	end



end
