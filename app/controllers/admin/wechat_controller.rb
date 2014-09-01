#encoding : UTF-8
module Admin
  class WechatController < Admin::BaseController

    @@appid='wxec23a03bf5422635'
    @@appsecret='b57aa686db378f60fe5e3b80b3bb412c'
    $openid='gh_a0e5b9a22803'

    # 创建一个实例
    #$client ||= WeixinAuthorize::Client.new(ENV["APPID"], ENV["APPSECRET"])
    def followers
      # @order_all = Ecstore::Order.where(:recommend_user=>wechat_user).select("sum(commission) as share").group(:recommend_user).first
     #sql ='SELECT openid,user_info,(select sum(commission) from mdk.sdb_b2c_orders where recommend_user= mdk.sdb_wechat_followers.openid group by recommend_user)  as commission FROM mdk.sdb_wechat_followers'
      message = '您还没有关注者'
      @followers =  Ecstore::WechatFollower.paginate(:page => params[:page], :per_page => 20).order("commission DESC")

      if current_admin == nil
        @supplier = Ecstore::Supplier.where(:member_id=>cookies["MEMBER"].split("-").first,:status=>1).first

        if @supplier
          @followers = @followers.where(:supplier_id=>@supplier.id)
        else
          return render :text=>message
        end
      end
      #更新佣金
      @followers.each do |follower|
        sql ="update mdk.sdb_wechat_followers set commission= (select sum(commission) from mdk.sdb_b2c_orders where recommend_user= '#{follower.openid}' group by recommend_user) where openid='#{follower.openid}'"
        ActiveRecord::Base.connection.execute(sql)
      end
      #@order_all = Ecstore::Order.where(:recommend_user=>wechat_user).select("sum(commission) as share").group(:recommend_user).first

      if params[:platform]=='vshop'
        render :layout=>'vshop_wechat'
      end
    end

    def follower_renew
      follower = params[:openid]
      @follower =  Ecstore::WechatFollower.find_by_openid(follower).first

      supplier = Ecstore::Supplier.find(@follower.supplier_id)
      appid = supplier.weixin_appid
      appsecret =  supplier.weixin_appsecret
      $client ||= WeixinAuthorize::Client.new(appid,appsecret)

      @follower.user_info = $client.user(openid).result.to_s
      @follower.save
    end

    def followers_import
      @supplier = Ecstore::Supplier.where(:member_id=>cookies["MEMBER"].split("-").first,:status=>1).first
      appid = @supplier.weixin_appid
      appsecret =  @supplier.weixin_appsecret

      $client ||= WeixinAuthorize::Client.new(appid,appsecret)
      if ($client.is_valid?)
      #获取关注者列表
       @followers = $client.followers.result
       @openids = @followers["data"]["openid"]
       @openids.each do |openid|
         @follower = Ecstore::WechatFollower.find_by_openid(openid)
         if ! @follower
           Ecstore::WechatFollower.new do |f|
             f.openid = openid
             f.supplier_id = @supplier.id
             f.user_info = $client.user(openid).result.to_s
           end.save
         end
       end
        redirect_to '/admin/wechat/followers?platform=vshop'
=begin
       s=''

       s = s+@followers.to_s
       return render :text=>s
{"total"=>8, "count"=>8, "data"=>{"openid"=>["oHwtut91xXfJLl-MfsRTKAfOgIgc", "oHwtut-sSG77G0ljiCsvTinUfy6c", "oHwtut5miGKpAvZrWgVjBoMH653c", "oHwtut4DCngIR1RsYriOvD2jjBn0", "oHwtut8zMrwoo2Nv2gi-zuHw3bDs", "oHwtut2KpAxjkvgey_a8TOxgcYaM", "oHwtut402wk_IvtnQzKFm6VSQJ5M", "oHwtut0HBG7SuncOZeOrx8K5mn8w"]}, "next_openid"=>"oHwtut0HBG7SuncOZeOrx8K5mn8w"}
=end


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
               "name":"婴童",
               "url":"http://www.trade-v.com/mgallery?name=%E5%A9%B4%E7%AB%A5"
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
            },
           {
               "type":"click",
               "name":"联系我们",
               "key" : "Oauth"
            }]
       }]
 }'
        #"url":"https://open.weixin.qq.com/connect/oauth2/authorize?appid=wxec23a03bf5422635&redirect_uri=http%3A%2F%2Fwww.trade-v.com%2Fauth%2Fweixin%2Fcallback&response_type=code&scope=snsapi_base&state=STATE#wechat_redirect"
#"url":"https://open.weixin.qq.com/connect/oauth2/authorize?appid=wxec23a03bf5422635&redirect_uri=http%3A%2F%2Fwww.trade-v.com%2Fauth%2Fweixin%2Fcallback&response_type=code&scope=snsapi_base&state=STATE#wechat_redirect"
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