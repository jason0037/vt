#encoding:utf-8
class CommentsController < ApplicationController

  def create
    return_url = params.delete(:return_url)
    @comment = Ecstore::Comment.new params[:comment]

    respond_to do |format|
      if @comment.save
        format.html { redirect_to return_url}
        format.js #{ render json: @comment, status: :created }
      else
        format.html { redirect_to return_url, :notice=>"提交评论失败" }
        format.js #{ render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end


  def tairyo_comment

    if @user
      @comment = Ecstore::Comment.new params[:comment]


    render layout: "tairyo_new"
    else
      redirect_to '/tlogin?return_url=tairyo/comment/'
    end
  end

 def tairyo
   if @user
     @comment = Ecstore::Comment.new params[:comment]

     if @comment.save

       redirect_to '/tairyo'
      else
       redirect_to'./comment'

     end
   else
     redirect_to '/tlogin?return_url=tairyo/comment/'
    end

 end

 end

