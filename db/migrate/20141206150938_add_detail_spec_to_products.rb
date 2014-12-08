class AddDetailSpecToProducts < ActiveRecord::Migration
  def change
    add_column :sdb_b2c_products, :detail_spec, "varchar(255)"

    #  '{"totalength"=>"货叉总长度","totalweigth"=>"货叉总宽度","forksize"=>"货叉尺寸","doublebearing">"承重轮(双轮)","singebearing">"承重轮(单轮)","sterring">"转向轮","highest">"货叉最高高度","lowest">"货叉最低高度","ratedload">"额定负载",}'

  end

  def connection
    @connection = Ecstore::Base.connection
  end
end