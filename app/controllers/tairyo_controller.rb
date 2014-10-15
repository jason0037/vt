class TairyoController < ApplicationController
  layout "tairyo"



  def index    #大渔饭店首页

    @comment_a=Ecstore::Comment.find_by_sql("select * from sdb_imodec_comments where member_id='2459'order by id desc ")

    end
   def show

   end
  def car

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
