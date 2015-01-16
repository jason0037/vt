#encoding:utf-8
class Patch::FilesController < ApplicationController






 def show
 @files =  Ecstore::Files.paginate(:per_page=>20,:page=>params[:files],:order=>"updated_at desc")
   clear_breadcrumbs
    @menu="techaical"
    add_breadcrumb("技术中心",:member_path)
     add_breadcrumb("资料下载")
     render :layout=> "page_cheuks"


    end










end
