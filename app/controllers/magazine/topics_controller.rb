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
