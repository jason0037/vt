# Use this hook to configure WeixinRailsMiddleware bahaviors.
WeixinRailsMiddleware.configure do |config|

  ## NOTE:
  ## If you config all them, it will use `weixin_token_string` default

  ## Config public_account_class if you SAVE public_account into database ##
  # Th first configure is fit for your weixin public_account is saved in database.
  # +public_account_class+ The class name that to save your public_account
   config.public_account_class = "Ecstore::Supplier"#Ecstore::PublicAccount"

  ## Here configure is for you DON'T WANT TO SAVE your public account into database ##
  # Or the other configure is fit for only one weixin public_account
  # If you config `weixin_token_string`, so it will directly use it
  #config.weixin_token_string = 'c51c4d8f4e770c86ba1c3da4'
  #config.weixin_token_string = 'c51c4d8f4e770c86ba1c4ad3'
  # using to weixin server url to validate the token can be trusted.
  #config.weixin_secret_string = '47y5oBQ_z2SNZPI-sKyblpvJmugcqXbd'
  #config.weixin_secret_string = '47y5oBQ_z2SNZPI-sKyblpvJmugcbdXq'

end
