#encoding : UTF-8
module Admin
  class WechatController < Admin::BaseController

    @@appid='wxec23a03bf5422635'
    @@appsecret='b57aa686db378f60fe5e3b80b3bb412c'
    $openid='gh_a0e5b9a22803'

    # 创建一个实例
    #$client ||= WeixinAuthorize::Client.new(ENV["APPID"], ENV["APPSECRET"])
    def followers
      @followers =  Ecstore::WechatFollower.paginate(:page => params[:page], :per_page => 20).order("created_at DESC")
    end

    def followers_import
      $client ||= WeixinAuthorize::Client.new(@@appid,@@appsecret)
      if ($client.is_valid?)
      #获取关注者列表
       @followers = $client.followers.result#["data"]["openid"]
      # @followers='["oVxC9uJKUrr8enKnzqdsbqcxNvXg", "oVxC9uGAGG5uV7NMQtEVmU5CHfJc", "oVxC9uDPnMmmc_ueMcu8w6ZASHoA", "oVxC9uBr12HbdFrW1V0zA3uEWG8c", "oVxC9uBh4jWni0MOK5EJHQwk2s1I", "oVxC9uPIQg2mf1x_-r0z-L-V8wug", "oVxC9uIDfT9iq_9iIWu54doVz3Vg", "oVxC9uNpGypfrQjWfnDM-XYq5Ubk", "oVxC9uOvUT_sHHDC5unBRdG-TxEg", "oVxC9uD0IhJL8EB-AGZFPBYPsF8k", "oVxC9uNa8Qil65iR4lYWtb9f6GEU", "oVxC9uHB9AOKp6-nWzCsJwcFu3Zc", "oVxC9uMny98wUvsdytUD3TF2zKIs", "oVxC9uK9CSjzd0nVmnfkqlAGj3kQ", "oVxC9uNp3UH8LiXYx0oRNCJpiu-8", "oVxC9uADvVLGWkwk4enHpYKDa88k", "oVxC9uOzYGWyfB0b81hmwbXs8wPI", "oVxC9uChJqM0nf-PREaLjk5Xf2MU", "oVxC9uGiazMZjmHdQ9KzrOQwoUW4", "oVxC9uCqeu1WPh2YDkM_PZXCp8Wc", "oVxC9uLZUk3q2qmqaaVY7woZW9ic", "oVxC9uJPkOo-SERYmHThvUeCoBBI", "oVxC9uBneu5YaQ_vd8BSvNFT7ojw", "oVxC9uAzwD1_VxugaWaUD8sSYjL0", "oVxC9uDGhK7ZEBqRdkjg8KCrNwak"]'
      #  sql ="insert mdk.sdb_wechat_followers (openid) values #{@followers.gsub('[','(').gsub(']',')').gsub(',','),(')}"
      #  ActiveRecord::Base.connection.execute(sql)
=begin
        Ecstore::WechatFollower.new do |wf|
          rl.wechat_id = @wechat_user
          rl.access_time = now
        end.save
=end
        #获取用户基本信息
=begin
        @followers =  Ecstore::WechatFollower.limit(5).offset(23)
        now  = Time.now

        @followers.each do |follower|
          openid=follower.openid
          follower.user_info = $client.user(openid).result.to_s
          follower.save
        end
=end
        render :text=> @followers


     end

    end

    def menu
      $openid='gh_a0e5b9a22803'
      $client ||= WeixinAuthorize::Client.new(@@appid,@@appsecret)
      if ($client.is_valid?)
        @menu = $client.menu.result['menu']['button']
      end
    end

    def menu_edit
      $openid='gh_a0e5b9a22803'
      $client ||= WeixinAuthorize::Client.new(@@appid,@@appsecret)

      if ($client.is_valid?)

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

    def groups
      $client ||= WeixinAuthorize::Client.new(@@appid,@@appsecret)
      if ($client.is_valid?)
        @groups = $client.groups.result['groups']
      else
        render :text=>'获取分组信息失败'
      end
    end

    def groups_create

      $client ||= WeixinAuthorize::Client.new(@@appid,@@appsecret)
      if ($client.is_valid?)
         $client.create_group("test22")
         @groups = $client.groups.result

      end
    end

    def batch_sending

    end

    def create

    end

    def update

    end

    def destroy

    end

  end

end