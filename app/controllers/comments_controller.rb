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




 end

