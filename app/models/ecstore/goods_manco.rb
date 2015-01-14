#encoding:utf-8
require 'csv'
require 'spreadsheet'

class Ecstore::GoodManco < Ecstore::Base

  NEW_GOOD_START_ID = 0  #2398

  self.table_name = "sdb_b2c_goods_manco"

  scope :selling, where(:marketable=>'true')

  attr_accessible :desc, :material, :mesure, :softness, :thickness, :elasticity, :fitness, :try_on,:price,:mktprice,:store,:name,
                            :cat_id,:brand_id,:supplier_id,:products_attributes,:member_id

  accessible_all_columns
  attr_accessor :up_or_down
  belongs_to :user,:foreign_key=>"member_id"
 belongs_to :cat,:class_name=>"Category",:foreign_key=>"cat_id"
 belongs_to :brand, :foreign_key=>"brand_id"
 belongs_to :supplier, :foreign_key=>"supplier_id"

 belongs_to :default_image, :foreign_key=>"image_default_id",:class_name=>"Image"

 has_many :order_items,:foreign_key=>"goods_id"
 has_many :image_attachs,  :foreign_key=>"target_id", :conditions=>{:target_type=>"goods"}

  has_many :images,	:through=>:image_attachs

  has_many :products, :foreign_key=>"goods_id",:class_name=>"Ecstore::Product",:dependent=>:destroy
  accepts_nested_attributes_for :products

  has_many :recommend_logs, :foreign_key=>"goods_id"
  has_many :good_specs, :foreign_key=>"goods_id"
  has_many :spec_values, :through=>:good_specs
  has_many :specs, :through=>:good_specs, :uniq=>true

  has_many :good_spec_items,:foreign_key=>"goods_id"

  has_one :seo, :foreign_key=>:pk,:conditions=>{ :mr_id => 2 }

  has_one :good_collocation, :foreign_key=>"goods_id"

  has_many :comments, :foreign_key=>"commentable_id",:conditions=>{ :commentable_type=>"goods" }

  include Ecstore::Metable

  belongs_to :good_type, :foreign_key=>"type_id"
  has_many :good_type_specs, :through=>:good_type

  has_many :tagables, :foreign_key=>"rel_id"
  has_many :tegs, :through=>:tagables

  def  self.export_xls(fields, goods)

    xls_report = StringIO.new
    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet :name => "Products"

    bold = Spreadsheet::Format.new :color => :black, :weight => :bold, :size => 10
    sheet1.row(0).default_format = bold

    sheet1.row(0).concat %w{类型  商品编号 规格货号 分类 品牌 商品名称 上架 规格 库存}
    field_count=9

    fields.each do |field|
      sheet1[0,field_count] = field
      field_count +=1
    end

    row_count=0
    row_conten=""
    goods.each do |good|
      row_count +=1
      sheet1.row(row_count).default_format = bold
      sheet1[row_count,0] = good.good_type&&good.good_type.name #类型
      sheet1[row_count,1] = good.bn.to_s  #商品编号
      sheet1[row_count,3] = good.cat&&good.cat.full_path_name #分类
      sheet1[row_count,4] = good.brand&&good.brand.brand_name #品牌
      sheet1[row_count,5] = good.name #商品名称
      sheet1[row_count,6] = good.marketable=="true" ? "Y" : "N" #上架
      sheet1[row_count,7] = good.specs.order("sdb_b2c_specification.spec_id asc").pluck(:spec_name).join("|") #规格

      good.products.each do |product|
        row_count +=1
        spec_values = product.spec_values.order("sdb_b2c_spec_values.spec_id asc").pluck(:spec_value).join("|")
        sheet1[row_count,0] = good.good_type&&good.good_type.name, #类型
            sheet1[row_count,1] = good.bn.to_s, #商品编号
            sheet1[row_count,2] = product.bn.to_s, #规格货号
            sheet1[row_count,5] = product.name, #商品名称
            sheet1[row_count,6] = product.marketable=="true" ? "Y" : "N", #上架
            sheet1[row_count,7] =  spec_values, #规格
            sheet1[row_count,8] = product.store #库存

        field_count=9
        if (fields.include?("进货价"))
          sheet1[row_count,field_count] = product.cost.to_f
          field_count +=1
        end
        if (fields.include?("渠道价"))
          sheet1[row_count,field_count] = product.bulk.to_f
          field_count +=1
        end
        if (fields.include?("渠道零售价"))
          sheet1[row_count,field_count] = product.promotion.to_f
          field_count +=1
        end
        if (fields.include?("批发价"))
          sheet1[row_count,field_count] = product.wholesale.to_f
          field_count +=1
        end
        if (fields.include?("会员价"))
          sheet1[row_count,field_count] = product.price.to_f
          field_count +=1
        end
        if (fields.include?("市场价"))
          sheet1[row_count,field_count] = product.mktprice.to_f
          field_count +=1
        end
      end
    end

    book.write xls_report
    xls_report.string
  end

  def self.export_cvs(fields, goods)
    field_name = [ '类型', '商品编号','规格货号','分类','品牌','商品名称','上架','规格','库存']
    #price_fields = convert_array(fields)  #csv文件的头（标题）
    field_name += fields

    output = CSV.generate do |csv|
      csv << field_name
      goods.each do |good|
        spec_names = good.specs.order("sdb_b2c_specification.spec_id asc").pluck(:spec_name).join("|")
        csv << [ good.good_type&&good.good_type.name, #类型
                 good.bn.to_s,  #商品编号
                 nil, #规格货号
                 good.cat&&good.cat.full_path_name, #分类
                 good.brand&&good.brand.brand_name, #品牌
                 good.name,#商品名称
                 good.marketable=="true" ? "Y" : "N", #上架
                 spec_names, #规格
                 good.store,  #库存
                 nil,#成本价
                 nil,  #渠道价
                 nil,  #渠道零售价
                 nil, #批发价
                 nil, #会员价
                 nil  #市场价
        ]

        good.products.each do |product|
          spec_values = product.spec_values.order("sdb_b2c_spec_values.spec_id asc").pluck(:spec_value).join("|")
          content = [ good.good_type&&good.good_type.name, #类型
                      good.bn.to_s, #商品编号
                      product.bn.to_s, #规格货号
                      nil, #分类
                      nil, #品牌
                      product.name, #商品名称
                      product.marketable=="true" ? "Y" : "N", #上架
                      spec_values, #规格
                      product.store #库存
          ]

          if (fields.include?("进货价"))
            content.push product.cost.to_f
          end
          if (fields.include?("渠道价"))
            content.push product.bulk.to_f
          end
          if (fields.include?("渠道零售价"))
            content.push product.promotion.to_f
          end
          if (fields.include?("批发价"))
            content.push product.wholesale.to_f
          end
          if (fields.include?("会员价"))
            content.push product.price.to_f
          end
          if (fields.include?("市场价"))
            content.push product.mktprice.to_f
          end

          csv << content
        end
      end
    end

  end

  def self.export_cvs_file(goods = [], file = "#{Rails.root}/public/tmp/goods.csv")

    CSV.open(file,"w:GB18030") do |csv|
      csv << [ '*:类型',
               'col:商品编号',
               'col:规格货号',
               'col:分类',
               'col:品牌',
               'col:市场价',
               'col:销售价',
               'col:商品名称',
               'col:上架',
               'col:规格',
               'col:库存',
               'col:商品描述'
      ]
      goods.each do |good|
        spec_names = good.specs.order("sdb_b2c_specification.spec_id asc").pluck(:spec_name).join("|")
        csv << [ good.good_type&&good.good_type.name, #类型
                 good.bn.to_s,  #商品编号
                 nil, #规格货号
                 good.cat&&good.cat.full_path_name, #分类
                 good.brand&&good.brand.brand_name, #品牌
                 nil,  #市场价
                 nil, #销售价
                 good.name,#商品名称
                 good.marketable=="true" ? "Y" : "N", #上架
                 spec_names, #规格
                 good.store,  #库存
                 good.desc #商品描述
        ]

        good.products.each do |product|
          spec_values = product.spec_values.order("sdb_b2c_spec_values.spec_id asc").pluck(:spec_value).join("|")
          csv << [ good.good_type&&good.good_type.name, #类型
                   good.bn.to_s, #商品编号
                   product.bn.to_s, #规格货号
                   nil, #分类
                   nil, #品牌
                   product.mktprice.to_f, #市场价
                   product.price.to_f,  #销售价
                   product.name, #商品名称
                   product.marketable=="true" ? "Y" : "N", #上架
                   spec_values, #规格
                   product.store, #库存
                   nil #商品描述
          ]
        end
      end
    end
    file
  end

  def collocation_goods
     return  self.good_collocation.collocations.collect do |goods_id|
        Ecstore::Good.find_by_goods_id(goods_id)
     end.compact if self.good_collocation&&self.good_collocation.collocations.present?
     return []
  end

  def has_cols?
      self.good_collocation.present? && self.collocation_goods.size > 0
  end

  def is_suit?
      cat = Ecstore::Category.where(:parent_id=>0,:cat_name=>SUIT_NAME).first

      return false unless cat
      self.cat_id == cat.cat_id
  end


  def rec_image
    pic = ""
    if !self.medium_pic.blank?
      if self.medium_pic.index("|") != -1
          pic = self.medium_pic.split("|").first
      else
          pic = self.medium_pic
      end
    end
  end

  def reco_collocation_goods
      cat = Ecstore::Category.find_by_cat_id(self.cat_id)
      cat.goods.where("goods_id <> ?", self.goods_id).order("goods_id desc").limit(10)
  end

  def savings
      if collocation_goods.present?
        collocation_goods.collect {|good| good.price}.inject(:+) - self.price
      else
        0
      end
  end

  def self.suits
      cat = Ecstore::Category.where(:parent_id=>0,:cat_name=>SUIT_NAME).first
      if cat
          # Ecstore::Good.where(:marketable=>'true',:cat_id=>cat.cat_id)
          Ecstore::Good.where("marketable = ? and cat_id = ? or p_50 = ?",'true',cat.cat_id,'true')
      else
          Ecstore::Good.where(:marketable=>'true')
      end
  end

  def self.gifts
    self.where(:goods_type=>"gift",:marketable=>'true')
  end


  def colors_serialize
      @colors_s ||= {}
  end

  def sizes_serialize
      @sizes_s ||= {}
  end

  def colors_a
    @colors_a ||= []
  end

  def sizes_a
    @sizes_a ||= []
  end

  def specs_desc_serialize
    spec = []
    spec.push @colors_s
    spec.push @sizes_s
    return spec.serialize
  end
  #  Params
  #  *return_type == 'record                        'SpecValue array
  #  *return_type == 'other                       'e_id array
  def color_specs(return_type='record')
     spec_color_id = 1
     return []  if self.spec_desc.blank?
     return [] if self.spec_desc[spec_color_id].blank?


     self.spec_desc[spec_color_id].collect do |private_spec_value_id,spec|
        if return_type == 'record'
          Ecstore::SpecValue.find(spec["spec_value_id"])
        else
          spec["spec_value_id"].to_i
        end
     end

     # self.good_specs.where(:spec_id=>1).pluck(:spec_value_id).uniq.collect do |spec_value_id|
     #    Ecstore::SpecValue.find(spec_value_id)
     # end.sort{ |x,y| x.p_order <=> y.p_order }
  end

  def size_specs
      spec_size_id = self.spec_desc.keys.select{ |e| e!=1 }.first
      self.spec_desc[spec_size_id].collect do |private_spec_value_id,spec|
          Ecstore::SpecValue.find(spec["spec_value_id"])
      end if self.spec_desc[spec_size_id].is_a?(Hash)
     # self.good_specs.where("spec_id <> 1").pluck(:spec_value_id).uniq.collect do |spec_value_id|
     #    Ecstore::SpecValue.find(spec_value_id)
     # end.sort{ |x,y| x.p_order <=> y.p_order }
  end

  def pictures(style=:large,color=nil,format=:jpg)
    return [] if self.big_pic.blank?

    pics = self.big_pic.split("|")

    return pics
    # return []  if color.blank?
    # pattern  = "#{Rails.root}/public/pic/product/#{self.bn}/#{style}/#{color}/*.#{format}"

    # Dir.glob(pattern).collect do  |file|
    #       "/pic/product/#{self.bn}/#{style}/#{color}/#{File.basename(file)}"
    # end.sort{|x,y| y<=>x}
  end

  def large_pictures(color,format=:jpg)
     pictures(:large,color)
  end

  def list_pictures(format=:jpg)
    pattern  = "#{Rails.root}/public/pic/product/#{self.bn}/list/*.#{format}"
    Dir.glob(pattern).collect do  |file|
            "/pic/product/#{self.bn}/list/#{File.basename(file)}"
    end.sort{|x,y| x<=>y}
  end

  def list_default_pic
    return self.medium_pic if !self.medium_pic.blank?
    # if self.goods_id > NEW_GOOD_START_ID
    #   list_pictures[0]
    # else
    #   pic = Ecstore::Image.find_by_image_id(self.image_default_id)
    #   return "http://www.i-modec.com/#{pic.s_url}" if pic
    #   nil
    # end
  end

  def list_hover_pic
    if self.goods_id > NEW_GOOD_START_ID
      list_pictures[1]
    else
      pic = Ecstore::Image.find_by_image_id(self.images_url)
      pic = self.images.order("attach_id desc").first unless pic
      pic = self.images.order("attach_id desc").last if  pic == Ecstore::Image.find_by_image_id(self.image_default_id)

      return "http://www.i-modec.com/#{pic.s_url}" if pic
      nil
    end
  end

  def home_pictures(format='jpg')
    pattern  = "#{Rails.root}/public/pic/product/#{self.bn}/list/*.#{format}"
    Dir.glob(pattern).collect do  |file|
            "/pic/product/#{self.bn}/list/#{File.basename(file)}"
    end.sort{ |x,y| x<=>y }
  end

  def home_picture_cover
     home_pictures.first
  end

  def home_suit_pic
      "/pic/product/#{self.bn}/home_suit_pic.jpg"
  end

  def suit_cover
      "/pic/product/#{self.bn}/suit_cover.gif"
  end

  def home_top_thumbnail
    "/pic/product/#{self.bn}/top.jpg"
  end


  def custom_picture(color,format=:jpg)
    pictures(:custom,color).first
  end

  def pictures_for_mobile(color,size_prefix,format='jpg')
    public_path = "#{Rails.root}/public"
    pattern  = "#{public_path}/pic/product/#{self.bn}/mobile/#{color}/#{size_prefix}_[0-9].#{format}"
    Dir.glob(pattern).collect do  |file|
            file[public_path]=""
            file
    end.sort{ |x,y| y<=>x }
  end

  def colors
    self.color_specs.collect do |spec|
       spec.alias.present? ? spec.alias.downcase : spec.spec_value.split(/\s+/).last.downcase
    end
  end

  def big_pictures_for_mobile(color)
    self.pictures_for_mobile(color,"b")
  end

  def small_pictures_for_mobile(color)
    self.pictures_for_mobile(color,"s")
  end

  def slides_for_mobile(format="jpg")
    public_path  = "#{Rails.root}/public"
    if self.colors.size > 1
      pattern  = "#{public_path}/pic/product/#{self.bn}/mobile/*/b_[13].#{format}"
    else
      pattern  = "#{public_path}/pic/product/#{self.bn}/mobile/*/b_[0-9].#{format}"
    end

    Dir.glob(pattern).collect do  |file|
            file[public_path]=""
            { :img=>file,:width=>320,:height=>451 }
    end.sort{ |x,y| y[:img]<=>x[:img] }.to_json
  end

  def list_cover_for_mobile
    self.small_pictures_for_mobile(self.colors.first).first
  end



  def favorited_by?(user)
    if user.is_a?(Ecstore::User)
        member_id =  user.member_id
    else
        member_id =  user.to_i
    end

    Ecstore::Favorite.where(:member_id=>member_id,
                                           :goods_id=>self.goods_id,
                                           :object_type=>"goods").size > 0
  end

  def default_product
      p = self.products.select{ |product| product.store.to_i > 0 }.first
      return self.products.first if p.blank?
      p
  end

  def spec_desc
     super.deserialize  if super.present?
  end

  def gift_image_url
    img = Ecstore::Image.find_by_image_id self.image_default_id
    "#{img.s_url}"
  end

  def up_at
    return nil if uptime.blank?
    return Time.at(uptime).strftime("%Y-%m-%d %H:%M:%S")
  end

  def down_at
    return nil if downtime.blank?
    return Time.at(downtime).strftime("%Y-%m-%d %H:%M:%S")
  end


  def store2
     products.collect{ |p| p.p_store}.inject(:+)
  end

end
