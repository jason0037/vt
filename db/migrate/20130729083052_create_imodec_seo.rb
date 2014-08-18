class CreateImodecSeo < ActiveRecord::Migration
 # def up
 #  	create_table :sdb_imodec_seo,:options=>"ENGINE=MyISAM DEFAULT CHARSET=utf8" do |t|
 #  		t.string :title
 #  		t.string :keywords
 #  		t.string :description
 #     t.references :metable, :polymorphic=>true
 #  	end
 # end

 def down
  	drop_table :sdb_imodec_seo
  end

  def connection
  	@connection  = Ecstore::Base.connection
  end

end
