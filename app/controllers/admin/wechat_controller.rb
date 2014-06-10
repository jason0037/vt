#encoding : UTF-8
module Admin
  class WechatController < Admin::BaseController

    appid='wxec23a03bf5422635'
    appsecret='b57aa686db378f60fe5e3b80b3bb412c'
    $openid='gh_a0e5b9a22803'

    # 创建一个实例
    #$client ||= WeixinAuthorize::Client.new(ENV["APPID"], ENV["APPSECRET"])

    def user_info

    end

    def index
      $client ||= WeixinAuthorize::Client.new(appid,appsecret)
     # $client ||= WeixinAuthorize::Client.new(ENV["APPID"], ENV["APPSECRET"])
     # return render :text=>$client.is_valid?
      if ($client.is_valid?)

        #获取用户基本信息
        #openid='oVxC9uChJqM0nf-PREaLjk5Xf2MU'
        #user_info = $client.user(openid).result
       # group = $client.create_group("test22")
       # groups = $client.groups.cn_msg

        #获取关注者列表
        #@followers = $client.followers
        menu = '{
     "button":[
     {
          "type":"click",
          "name":"限时特价",
          "key":"ON_SALE"
      },
      {
           "type":"click",
           "name":"新品推荐",
           "key":"NEW"
      },
      {
           "name":"商品分类",
           "sub_button":[
           {
               "type":"view",
               "name":"总统奶酪",
               "url":"http://www.trade-v.com/gallery/556?gtype=1&from=weixin"
            },
            {
               "type":"view",
               "name":"总统黄油",
               "url":"http://www.trade-v.com/gallery/557?gtype=1&from=weixin"
            },
            {
               "type":"view",
               "name":"精选茶叶",
               "url":"http://www.trade-v.com/gallery/557?gtype=1&from=weixin"
            }]
       }]
 }'
        response = $client.create_menu(menu)
        #response = $client.menu
        render :text=> response.cn_msg#.result#response.en_msg#user_info# @followers #JSON.parse(@user_info)
      end
    end

    def new

    end

    def edit

    end

    def create

    end

    def update

    end

    def destroy

    end

  end

end