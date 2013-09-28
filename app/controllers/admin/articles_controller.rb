class Admin::ArticlesController < Admin::BaseController
  before_filter :require_permission!
  def index
    @articles = Imodec::Article.paginate(:page => params[:page], :per_page => 20).order("created_at DESC")

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @articles }
    end
  end

  def new
    @article = Imodec::Article.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @article }
    end
  end

  def edit
    @article = Imodec::Article.find(params[:id])
  end

  def create
    @article = Imodec::Article.new(params[:imodec_article])

    if @article.published
      @article.published_at = Time.now
    end
    respond_to do |format|
      if @article.save
        format.html { redirect_to admin_articles_path, notice: 'Article was successfully created.' }
        format.json { render json: @article, status: :created, location: @article }
      else
        format.html { render action: "new" }
        format.json { render json: @article.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @article = Imodec::Article.find(params[:id])

    respond_to do |format|
      if @article.update_attributes(params[:imodec_article])
        format.html { redirect_to admin_articles_url, notice: 'Article was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @article.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @article = Imodec::Article.find(params[:id])
    @article.destroy

    respond_to do |format|
      format.html { redirect_to admin_articles_url }
      format.json { head :no_content }
    end
  end

  def set_position
    @article = ::Imodec::Article.find(params[:id])
    @article_prev = ::Imodec::Article.find_by_position_id(params[:position_id])
    if @article_prev
      @article_prev.position_id = nil
    end
    
    respond_to do |format|
      if @article.update_attribute("position_id", params[:position_id].to_i)
        if @article_prev
          @article_prev.save!
          format.json { render json: {article_prev_id: @article_prev.id} }
        else
          format.json { render json: {article_prev_id: 0} }
        end
      else
        format.json { render json: @article.errors, status: :unprocessable_entity }
      end
    end

    # respond_to do |format|
    #   # format.json { head :ok }
    #   format.json { render json: @article.errors }
    # end
  end

end
