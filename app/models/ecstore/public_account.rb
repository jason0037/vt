#encoding:utf-8
include WeixinRailsMiddleware::AutoGenerateWeixinTokenSecretKey
class Ecstore::PublicAccount < Ecstore::Base
  self.table_name = 'public_accounts'
  self.accessible_all_columns

  attr_accessor :weixin_secret_key,:weixin_token,:supplier_id


end