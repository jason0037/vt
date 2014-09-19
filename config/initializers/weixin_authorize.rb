# 这里修改成你的的命名空间。
#namespace = "app_name_weixin:weixin_authorize"
#redis = Redis.new(:host => "127.0.0.1", :port => "6379", :db => 15)

# 每次重启时，会把当前的命令空间所有的access_token 清除掉。
#exist_keys = redis.keys("#{namespace}:*")
#exist_keys.each{|key|redis.del(key)}

# Give a special namespace as prefix for Redis key, when your have more than one project used weixin_authorize, this config will make them work fine.
#redis = Redis::Namespace.new("#{namespace}", :redis => redis)

#WeixinAuthorize.configure do |config|
#  config.redis = redis
#end