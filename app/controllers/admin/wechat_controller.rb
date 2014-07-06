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
      appid='wxec23a03bf5422635'
      appsecret='b57aa686db378f60fe5e3b80b3bb412c'
      $openid='gh_a0e5b9a22803'
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
          "name":"限时特价",
          "sub_button":[
          {
                "type":"click",
                "name":"限时特价",
                "key":"ON_SALE"
            },
            {
                 "type":"click",
                 "name":"新品推荐",
                 "key":"NEW"
            }

      ]},
      {
           "name":"商品分类",
           "sub_button":[
           {
               "type":"view",
               "name":"乳制品",
               "url":"http://www.trade-v.com/mgallery?name=%E5%A5%B6%E9%85%AA"
            },
            {
               "type":"view",
               "name":"酒类",
               "url":"http://www.trade-v.com/mgallery?name=%E9%85%92%E7%B1%BB"
            },
            {
               "type":"view",
               "name":"零食",
               "url":"http://www.trade-v.com/mgallery?name=%E9%9B%B6%E9%A3%9F"
            },
            {
               "type":"view",
               "name":"肉类",
               "url":"http://www.trade-v.com/mgallery?name=%E8%82%89%E7%B1%BB"
            }]
         },
         {
           "name":"我的订单",
           "sub_button":[
           {
               "type":"view",
               "name":"我的订单",
               "url":"http://www.trade-v.com/goods?platform=mobile"
            },

            {
               "type":"click",
               "name":"我的佣金",
               "key":"SHARE"
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