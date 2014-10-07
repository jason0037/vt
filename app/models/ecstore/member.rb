# coding: utf-8
require 'digest/md5'
require 'csv'

class Ecstore::Member < Ecstore::Base
	self.table_name = "sdb_b2c_members"
	belongs_to :account,:foreign_key=>"member_id"
	belongs_to :member_lv,:foreign_key=>"member_lv_id"
	belongs_to :tag,:foreign_key=>"member_id"
	belongs_to :user,:foreign_key=>"member_id"


	def reg_time
		return #Time.at(self.regtime).strftime("%Y-%m-%d %H:%M:%S")
	end

	def sex_name
		if sex == "0"
			sex_name = "女"
		elsif sex == "1"
			sex_name = '男'
		else
			sex_name = ''
		end
		return sex_name
	end

	def email_validate_name
		if email_validate == "false"
			email_validate_name = "未验证"
		else
			email_validate_name = "已验证"
		end
		return email_validate_name
	end

	def sms_validate_name
		if sms_validate == "false"
			sms_validate_name = "未验证"
		else
			sms_validate_name = "已验证"
		end
		return sms_validate_name
	end

	def self.convert_array(fields)
		new_fields = []
		fields.each do |field|
			new_fields.push field.split("-")[2]
		end
		return new_fields
	end

	def self.export(fields,members)
	    field_name = convert_array(fields)  #csv文件的头（标题）
	    output = CSV.generate do |csv|
	      csv << field_name
	      members.each do |member|
	      	content = []
	      	if(fields.include?("1-member_id-会员ID"))
	      		content.push member.member_id
	      	end
	      	if (fields.include?("10-account_name-用户名"))
	      		if member.account.nil?
	      			content.push ""
	      		else
	      			content.push member.account.login_name 
	      		end	
	      	end
	        if(fields.include?("11-name-姓名"))
	      		if member.name.nil?
	      			content.push "" 
	      		else
	      			content.push member.name
	      		end
	      	end
	      	if(fields.include?("12-member_lv_id-会员等级"))
	      		if member.member_lv.nil?
	      			content.push "" 
	      		else
	      			content.push member.member_lv.name 
	      		end
	      	end
	      	if(fields.include?("13-email-邮箱"))
	      		if member.email.nil?
	      			content.push "" 
	      		else
	      			content.push member.email
	      		end
	      	end
	      	if(fields.include?("14-tag-标签"))
	      		if member.tag.nil?
	      			content.push "" 
	      		else
	      			content.push member.tag.getTagName
	      		end
	      	end
	      	if(fields.include?("15-mobile-手机"))
	      		if member.mobile.nil?
	      			content.push "" 
	      		else
	      			content.push member.mobile
	      		end
	      	end
	      	if(fields.include?("16-job-从事职业"))
	      		if member.user.job.nil?
	      			content.push "" 
	      		else
	      			content.push member.user.job
	      		end
	      	end
	      	if(fields.include?("17-income-家庭月收入"))
	      		if member.user.income.nil?
	      			content.push "" 
	      		else
	      			content.push member.user.income
	      		end
	      	end
	      	if(fields.include?("18-education-教育程度"))
	      		if member.education.nil?
	      			content.push "" 
	      		else
	      			content.push member.education
	      		end
	      	end
	      	if(fields.include?("19-gift-注册有礼"))
	      		if member.user.gift.nil?
	      			content.push "" 
	      		else
	      			content.push member.user.gift
	      		end
	      	end
	      	if(fields.include?("20-weight-体重"))
	      		if member.user.weight.nil?
	      			content.push "" 
	      		else
	      			content.push member.user.weight
	      		end
	      	end
	      	if(fields.include?("21-colors-喜欢的颜色"))
	      		if member.user.colors.nil?
	      			content.push "" 
	      		else
	      			content.push member.user.colors
	      		end
	      	end
	      	if(fields.include?("22-price-常买衣服的价位"))
	      		if member.user.price.nil?
	      			content.push "" 
	      		else
	      			content.push member.user.price
	      		end
	      	end
	      	if(fields.include?("23-places-常出席的场合"))
	      		if member.user.places.nil?
	      			content.push "" 
	      		else
	      			content.push member.user.places
	      		end
	      	end
	      	if(fields.include?("24-height-身高"))
	      		if member.user.height.nil?
	      			content.push "" 
	      		else
	      			content.push member.user.height
	      		end
	      	end
	      	if(fields.include?("25-shoesize-鞋码"))
	      		if member.user.shoesize.nil?
	      			content.push "" 
	      		else
	      			content.push member.user.shoesize
	      		end
	      	end
	      	if(fields.include?("26-interests-兴趣爱好"))
	      		if member.user.interests.nil?
	      			content.push "" 
	      		else
	      			content.push member.user.interests
	      		end
	      	end
	      	if(fields.include?("27-voc-所属行业"))
	      		if member.user.voc.nil?
	      			content.push "" 
	      		else
	      			content.push member.user.voc
	      		end
	      	end
	      	if(fields.include?("28-email_validate-邮箱验证"))
	      		if member.email_validate.nil?
	      			content.push "" 
	      		else
	      			content.push member.email_validate_name
	      		end
	      	end
	      	if(fields.include?("29-sms_validate-手机验证"))
	      		if member.sms_validate.nil?
	      			content.push "" 
	      		else
	      			content.push member.sms_validate_name
	      		end
	      	end
          if(fields.include?("30-supplier_id-供应商"))
            if member.account.supplier_id.nil?
              content.push ""
            else
              content.push member.account.supplier_id
            end
          end

	      	if(fields.include?("5-order_num-订单数"))
	      		if member.order_num.nil?
	      			content.push "" 
	      		else
	      			content.push member.order_num
	      		end
	      	end
	      	if(fields.include?("6-regtime-注册时间"))
	      		if member.regtime.nil?
	      			content.push "" 
	      		else
	      			content.push Time.at(member.regtime).strftime("%Y-%m-%d %H:%M:%S")
	      		end
	      	end
	      	if(fields.include?("7-point-积分"))
	      		if member.point.nil?
	      			content.push "" 
	      		else
	      			content.push member.point
	      		end
	      	end
	      	if(fields.include?("9-sex-性别"))
	      		if member.sex_name.nil?
	      			content.push "" 
	      		else
	      			content.push member.sex_name
	      		end
          end
          if(fields.include?("9-sex-性别"))
            if member.sex_name.nil?
              content.push ""
            else
              content.push member.sex_name
            end
          end
	        csv << content   # 将数据插入数组中
	      end
	    end
	end
end