class Blog::ArticlesController < Blog::BaseController

  # before_filter :authorize_user!,:except=>[:show]
  # before_filter :authorize_for_article,:only=>[:show]

  def index
    @articles = Imodec::Article.where("published = ?",true).paginate(:page => params[:page], :per_page => 20).order("created_at DESC")
    @headlined_articles = Imodec::Article.where("published = ? AND headlined = ?",true,true).order("position_id ASC").limit(8)
  end

  def show
    @article = Imodec::Article.find(params[:id])
    @headlined_articles = Imodec::Article.where("published = ? AND headlined = ?",true,true).order("position_id ASC").limit(8)
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @article }
    end
  end

end
