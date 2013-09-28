#encoding:utf-8
class Ecstore::Aftersale < Ecstore::Base
	self.table_name = "sdb_aftersales_return_product"

	self.accessible_all_columns


	attr_accessible :items
	attr_accessor :items

	validates_presence_of :content, :message=>"必须填写详细说明"
	# validates_presence_of :items, :message=>"必须选择商品"

	validate :check_items

	def check_items
		if self.items.select{ |item| item[:checked] == "true" }.blank?
			errors.add(:items,"必须选择商品")
			return false
		end
	end


      before_create :generate_return_id, :set_product_data

      def generate_return_id
      		self.return_id =  self.class.generate_return_id
      		self.return_bn = self.return_id.to_s
      end

      def set_product_data
      		data = []
      		self.items.each do |item|
      			if item[:checked] == "true"
      				data << { :bn=>item[:bn], :name=>item[:name], :num=>item[:num].to_i }
      			end
      		end
      		self.product_data = data.serialize2
      end

	def self.generate_return_id
          seq = rand(0..9999)
          loop do
              seq = 1 if seq == 9999
              _order_id = Time.now.strftime("%Y%m%d%H") + ( "%04d" % seq.to_s )
              return _order_id unless  Ecstore::Aftersale.find_by_return_id(_order_id)
              seq += 1
          end
       end

       def product_data
       	return super.deserialize.values if super.present?
       	super
       end

       def add_at
       	if add_time
       		Time.at(add_time).strftime("%Y-%m-%d %H:%M:%S")
       	else
       		nil
       	end
       end



	# '1' => '未操作'
	# '2' => '审核中'
	# '3' => '接受申请'
	# '4' => '完成'
	# '5' => '拒绝'
	# '6' => '已收货'
	# '7' => '已质检'
	# '8' => '补差价'
	# '9' => '已拒绝退款'
	def status_text
		case status
			when '1' then '未操作'
			when '2' then '审核中'
			when '3' then '接受申请'
			when '4' then '完成'
			when '5' then '拒绝'
			when '6' then '已收货'
			when '7' then '已质检'
			when '8' then '补差价'
			when '9' then '已拒绝退款'
			else ''
		end
	end

	# '1' => app::get('aftersales')->_('申请中'),
	# '2' => app::get('aftersales')->_('审核中'),
	# '3' => app::get('aftersales')->_('接受申请'),
	# '4' => app::get('aftersales')->_('完成'),
	# '5' => app::get('aftersales')->_('拒绝'),
	def front_status_text
		case status
			when '1' then '申请中'
			when '2' then '审核中'
			when '3' then '接受申请'
			when '4' then '完成'
			when '5' then '拒绝'
			else ''
		end
	end




end