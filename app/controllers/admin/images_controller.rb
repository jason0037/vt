#encoding:utf-8
require 'RMagick'
class Admin::ImagesController < Admin::BaseController
  include Magick
  before_filter :require_permission!
  def index
  	@water_options = {  "gray small"=>"watermark_gray_small.png",
                                      "gray normal"=>"watermark_gray_normal.png",
  						"white small"=>"watermark_white_small.png",
  						"white normal"=>"watermark_white_normal.png"
  						}

      if params[:start]
  		@start_time = params[:start]
  		@end_time = params[:end] || Time.now.to_s(:db)
  	else
  		@start_time = Time.now.strftime("%Y-%m-%d") + " 00:00:00"
  		@end_time = Time.now.to_s(:db)
  	end
  	@goods = Ecstore::Good.where("uptime >= ? and uptime < ?",Time.parse(@start_time).to_i,Time.parse(@end_time).to_i).order("last_modify DESC")
  end

  def mark
  	if params[:mark]
  		@start_time = params[:mark][:start]
  		@end_time = params[:mark][:end]
  		@goods = ::Ecstore::Good.where("uptime >= ? and uptime < ?",Time.parse(@start_time).to_i,Time.parse(@end_time).to_i)
  	end

  	water_logger.debug("[begin][#{Time.now}] **********begin***********")

  	mark_file = "public/watermarks/#{params[:mark][:water]}"
  	water_logger.debug("[info][#{Time.now.to_s(:db)}] watermark file is '#{mark_file}'")

	mark = Magick::Image.read(mark_file).first
  	@goods.each do |good|
  		good.images.each do |image|
  			src = "#{ECSTORE_ROOT_PATH}/#{image.m_url}"
  			# middle = "#{ECSTORE_ROOT_PATH}/#{image.m_url}"
  			# ar = middle.split("/")
  			# ar.pop
  			# `mkdir -p #{ar.join("/")}`
  			if File.exist?(src)
                        #backup src file end with .timestamp(1.jgp -> 1.jpg.1351844151)
                        `cp #{src} #{src}.#{Time.now.to_i}`
                        water_logger.debug("[info][#{Time.now.to_s(:db)}] file '#{src}' backup")
  				begin
  					origin = Magick::Image.read(src).first
		  			composited = origin.composite(mark,SouthEastGravity,10,10,OverCompositeOp)
		  	  		composited.write(src)
		  	  		# resized = origin.resize(344,485)
		  	  		# resized.write(middle)
		  	      		water_logger.debug("[info][#{Time.now.to_s(:db)}][#{good.bn}] file '#{src}' composited.")
  				rescue Exception => e
  					water_logger.debug("[error][#{Time.now.to_s(:db)}][#{good.bn}] file '#{src}'  #{e}.")
  				end
	  	    	else
	  	    		water_logger.debug("[info][#{Time.now.to_s(:db)}][#{good.bn}] file '#{src}' is not exists.")
	  	    	end

  		end
  	end
  	water_logger.debug("[end][#{Time.now.to_s(:db)}] *********end***********")
	

  	render "mark"
  end

  def rollback
     if params[:start]
      @start_time = params[:start]
      @end_time = params[:end] || Time.now.to_s(:db)
    else
      @start_time = Time.now.strftime("%Y-%m-%d") + " 00:00:00"
      @end_time = Time.now.to_s(:db)
    end
    @goods = Ecstore::Good.where("uptime >= ? and uptime < ?",Time.parse(@start_time).to_i,Time.parse(@end_time).to_i)
    water_logger.debug("[begin][#{Time.now}] **********begin rollbacking***********")
    @goods.each do |good|
        good.images.each do |image|
          src = "#{ECSTORE_ROOT_PATH}/#{image.m_url}"
          if File.exists?(src)
              origin_id = Dir.new(File.dirname(src)).collect do |f|
                                parts = f.split(".")
                                parts[2].to_i if !File.directory?(f) && parts.size > 2 
                              end.compact.min
              if origin_id
                origin_file = "#{src}.#{origin_id}" 
                result = `cp -f #{origin_file} #{src}`
                result = "successful" if result.blank?
                water_logger.debug("[info][#{Time.now}][#{good.bn}] #{src} is rollback,Message=#{result}")
              else
                water_logger.debug("[info][#{Time.now}][#{good.bn}] #{src} is already original file")
              end
          else
                water_logger.debug("[info][#{Time.now}][#{good.bn}] #{src} is not exists")
          end
        end
    end
     water_logger.debug("[begin][#{Time.now}] **********end rollback***********")

    render :text=>"completed"
  end

  def refresh
      Ecstore::Category.refresh_goods_cat_count
      render :js=>"alert('更新完成!');"
  end
end
