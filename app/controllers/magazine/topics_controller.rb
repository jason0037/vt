#encoding:utf-8
require 'pp'
class Magazine::TopicsController < Magazine::BaseController
  # layout nil, :only => [:more]

  # skip_before_filter :authorize_user!, :only=>[:show, :list]

  # before_filter :authorize_topic,:only=>[:show]

  def index
    if params[:category_id].present?
        @cat = Imodec::Category.find_by_id(params[:category_id])
        @topics = Imodec::Topic.where(:category_id=>params[:category_id])
    else
        @topics = Imodec::Topic.joins(:category).where("categories.name <> ?", "摩登报道")
    end

    @topics = @topics.published.paginate(:page => params[:page], :per_page => 20).order("created_at DESC") 
    
  end

  def show
    @topic = Imodec::Topic.find(params[:id])
    @comments = @topic.comments.paginate(:page => params[:page], :per_page => 3,:order=>"created_at desc")
    if params[:id]=='2015sakura'
      tag_id = params[:id]

      @goods = Ecstore::Good.where("goods_id=26062 or cat_id in (561,584)").order("goods_id DESC")

     end

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
        #  rl.goods_id = @good.goods_id
        rl.member_id = member_id
        rl.terminal_info = request.env['HTTP_USER_AGENT']
        #   rl.remote_ip = request.remote_ip
        rl.access_time = now
      end.save
      session[:recommend_user]=@recommend_user
      session[:recommend_time] =now
    end

    if params[:platform]=='mobile'
      render :layout=>"tradev"
    end

    # render :layout=>"new_magazine" if @topic.body.blank?
  end

  def more
    # layout nil
    if params[:category_id].present?
        @topics = Imodec::Topic.where(:category_id=>params[:category_id])
    else
        @topics = Imodec::Topic.joins(:category).where("categories.name <> ?","摩登报道")
    end
    
    @topics = @topics.published.paginate(:page => params[:page], :per_page => 20).order("created_at DESC")
    render :layout=>nil
  end

  def list
  	@topics = Imodec::Topic.where(:cover_size=>"big", :published => true).paginate(:page => params[:page], :per_page => 9).order("created_at DESC")
  	@topics.each do |topic|
      topic.body = topic.cover.url(topic.cover_size)
      format="%Y-%m-%d"
      topic.title = topic.created_at.strftime(format)
      topic.summary = @topics.total_pages
    end
	  respond_to do |format|
        format.xml { render xml: @topics, :status => :ok}
    end
  end

  private 
  def authorize_topic
     topic = Imodec::Topic.find(params[:id])
     return authorize_user! if topic.require_login
  end

end
