class TairyoController < ApplicationController




  def index    #大渔饭店首页
        @supplier=Ecstore::Supplier.find("99")

    @comment_a=Ecstore::Comment.find_by_sql("select * from sdb_imodec_comments where member_id='2459'order by id desc ")

    end
   def show

   end
  def map
    supplier_id=params[:supplier_id]
    @supplier=Ecstore::Supplier.find(supplier_id)
    render :layout => @supplier.layout
  end


  def comment
    supplier_id=params[:supplier_id]
    @supplier=Ecstore::Supplier.find(supplier_id)
    render :layout => @supplier.layout
  end

  def bus

  end
  def walk

  end
       #团购
  def group

  end

  def tese

  end


  def user

  end
end
