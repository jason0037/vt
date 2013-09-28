#encoding:utf-8
class Ecstore::Promotion < Ecstore::Base
  self.table_name = 'sdb_imodec_promotions'
  self.accessible_all_columns

  attr_accessor :cat_ids, :brand_ids, :bns
  attr_accessible :cat_ids, :brand_ids, :bns

  serialize :goods,  Array
  serialize :field_vals,  Array


  [:cat_id,:brand_id,:bn].each do |fake_field|
    class_eval <<-EVAL,__FILE__,__LINE__+1
        def #{fake_field}s
           arr = self.field_vals if self.field_name == '#{fake_field}'
           return [] if arr.blank?
           arr
        end
    EVAL
  end

  





  def enable?
      return false  unless  self.enable
  	now =  Time.now
       if self.begin_at.blank? && self.end_at.blank?
          return true
       end
       if self.begin_at.blank? && self.end_at.present?
           return self.end_at >= now
       end
       if self.begin_at.present? && self.end_at.blank?
          return self.begin_at <= now
       end
       return (self.begin_at <= now&& self.end_at >= now)
  end


  def self.matched_promotions(line_items = [])
       now = Time.now
       pmts = []
       where("begin_at < ? and end_at > ? and promotion_type = ? and enable = true", now, now,"order").order("priority desc").each do |promotion|
          if promotion.test_condition(line_items)
              if promotion.exclusive
                pmts << promotion
                break
              else
                pmts << promotion
              end
          end
       end
       pmts
  end

  def pmt_amount(line_items = [])
    order_total   = line_items.collect { |line_item| line_item.product.price * line_item.quantity }.inject(:+).to_i
    return self.action_val if self.action_type == 'order_minus'
    return order_total - (order_total*self.action_val/100).round if self.action_type == 'order_discount'
    0
  end



  def test_condition(line_items = [])
    order_total  = line_items.collect { |line_item| line_item.product.price * line_item.quantity }.inject(:+).to_i
    order_goods_count = line_items.collect { |line_item|  line_item.quantity.to_i }.inject(:+) || 0

    x = self.condition_val.to_i
    # 订单满X元
    if self.condition_type == 'order_amount_ge_x'
        return order_total >= x
    end
    # 订单商品数量满X件
    if self.condition_type == 'order_count_ge_x'
      return order_goods_count >= x
    end

    # 无条件(所有订单)
    if self.condition_type == 'none'
      return true
    end

    false
  end



  def self.matched_goods_promotions(line_items = [])
      now = Time.now
      pmts = []
      where("begin_at < ? and end_at > ? and promotion_type = ? and enable = true", now, now, "goods" ).order("priority desc").each do |promotion|
          if promotion.test_goods_condition(line_items)
              if promotion.exclusive
                pmts << promotion
                break
              else
                pmts << promotion
              end
          end
      end
      pmts
  end

  def test_goods_condition(line_items = [])

     # if self.goods.present?
     #      _specified_goods = self.goods & line_items.collect{ |line_item| line_item.good.bn }
     # else
     #     _specified_goods = line_items.collect{ |line_item| line_item.good.bn }
     # end
     if self.field_name.blank?
        _specified_goods = line_items.collect {|line_item| line_item.good}
     else
        if self.in_or_not == 'in'
            _specified_goods = line_items.select { |line_item| self.field_vals.include?(line_item.good.send(self.field_name).to_s) }.collect{|line_item| line_item.good}
        else
            _specified_goods = line_items.select { |line_item| !self.field_vals.include?(line_item.good.send(self.field_name).to_s) }.collect{|line_item| line_item.good}
        end
     end

     return false if _specified_goods.size == 0

     x = self.condition_val

     if self.condition_type == 'goods_total_ge_x'
        goods_total = line_items.select{ |line_item| _specified_goods.include?(line_item.good) }.collect do |line_item|
          line_item.product.price * line_item.quantity.to_i
        end.inject(:+)

        return goods_total >= x.to_i
     end

     if self.condition_type == 'goods_count_ge_x'
        goods_count = line_items.select{ |line_item| _specified_goods.include?(line_item.good) }.collect do |line_item|
          lline_item.quantity.to_i
        end.inject(:+)

        return goods_count >= x.to_i
     end

     return true  if self.condition_type == 'none'

     false

  end

  def goods_pmt_amount(line_items = [])
      
      if self.field_name.blank?
        _specified_goods = line_items #.collect {|line_item| line_item.good}
      else
        if self.in_or_not == 'in'
            _specified_goods = line_items.select { |line_item| self.field_vals.include?(line_item.good.send(self.field_name).to_s) }
        else
            _specified_goods = line_items.select { |line_item| !self.field_vals.include?(line_item.good.send(self.field_name).to_s) }
        end
      end

      return 0  if _specified_goods.size == 0
      y = self.action_val

      if self.action_type == 'good_price_minus'
          return _specified_goods.collect { |line_item| y*line_item.quantity.to_i  }.inject(:+)
      end

      if self.action_type == 'good_price_discount'

          return _specified_goods.collect { |line_item| (line_item.product.price - (y*line_item.product.price/100).round) * line_item.quantity.to_i }.inject(:+)
      end

      if self.action_type == 'goods_total_minus'
          return y
      end

      if self.action_type == 'goods_total_discount'
          goods_total = line_items.select{ |line_item| _specified_goods.include?(line_item.good) }.collect do |line_item|
            line_item.product.price * line_item.quantity.to_i
          end.inject(:+)

          return goods_total - (goods_total * y/100).round
      end

      0
  end
  

  def action_val=(val)
    super(val.to_s)
  end

  def action_val
    return eval(super) unless new_record?
    super
  end

  


end