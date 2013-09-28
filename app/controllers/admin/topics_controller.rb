class Admin::TopicsController < Admin::BaseController
  before_filter :require_permission!
  def index
    @topics = Imodec::Topic.paginate(:page => params[:page], :per_page => 20).order("created_at DESC")

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @topics }
    end
  end

  def new
    @topic = Imodec::Topic.new
    @create_or_update_path = admin_topics_path

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @topic }
    end
  end

  def edit

    @topic = Imodec::Topic.find(params[:id])
    @create_or_update_path = admin_topic_path(@topic)
  end

  def create
    @topic = Imodec::Topic.new(params[:imodec_topic])

    if @topic.published
      @topic.published_at = Time.now
    end

    respond_to do |format|
      if @topic.save
        format.html { redirect_to edit_admin_topic_url(@topic), notice: 'Topic was successfully created.' }
        format.json { render json: @topic, status: :created, location: @topic }
      else
        format.html { render action: "new" }
        format.json { render json: @topic.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @topic = Imodec::Topic.find(params[:id])
    if params[:imodec_topic] && params[:imodec_topic][:published] && @topic.published_at == nil
      @topic.published_at = Time.now
    end

    respond_to do |format|
      if @topic.update_attributes(params[:imodec_topic])
        format.html { redirect_to edit_admin_topic_url(@topic), notice: 'Topic was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @topic.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @topic = Imodec::Topic.find(params[:id])
    @topic.destroy

    respond_to do |format|
      format.html { redirect_to admin_topics_url }
      format.json { head :no_content }
    end
  end

  def set_position
    @topic = ::Imodec::Topic.find(params[:id])
    @topic_prev = ::Imodec::Topic.find_by_position_id(params[:position_id])
    if @topic_prev
      @topic_prev.position_id = nil
    end
    
    respond_to do |format|
      if @topic.update_attribute("position_id", params[:position_id].to_i)
        if @topic_prev
          @topic_prev.save!
          format.json { render json: {topic_prev_id: @topic_prev.id} }
        else
          format.json { render json: {topic_prev_id: 0} }
        end
      else
        format.json { render json: @topic.errors, status: :unprocessable_entity }
      end
    end
  end

  def published_at
      @topic = ::Imodec::Topic.find(params[:id])
      @topic.update_attribute :published_at,params[:published_at]
      render :nothing=>true
  end

end
