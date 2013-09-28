module Blog
	module BaseHelper
		def truncate2(content,options={})
                 return nil unless content

                 options = {:length=>13}.merge(options)
                 length = options[:length].to_f
                 content = strip_tags(content).gsub(/&[a-zA-Z]{1,10};/,'').strip
                 
                 len = 0.0
                 index = 0
                 content.scan(/./).each_with_index do |c,i|
                    if c.ord <= 255
                      len += 0.5
                    else
                      len +=1
                    end
                    if len >= length
                      index = i
                      break;
                    end
                 end

                 if index>0
                   content.slice(0,index)+'...'
                 else
                   content
                 end
              end
	end
end