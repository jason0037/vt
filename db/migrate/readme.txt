==================================================================

由于是连接两个数组库，所以数据迁移的时候需注意是给哪个库进行操作:

1). 博客数据库(配置文件:database.yml)

2). 商店数据库(配置文件:ecstore.yml)
 a)创建好迁移文件之后,需要添加如下一个方法:
 	def connection
  		@connection = Ecstore::Base.connection
  	end
  这样,'rake db:migrate' 自动会执行到商店数据库.

 b)由于商店数据库和博客数据库字符编码不一致,商店数据库创建表的时候需要添加以下配置:
 create_table :table_name,:options => 'ENGINE=MyISAM DEFAULT CHARSET=utf8' do |t|

 end

 可以参考文件 20121228063639_create_spec_items.rb
