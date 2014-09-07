#encoding : UTF-8
module Admin
  class WechatController < Admin::BaseController
=begin
    if cookies["MEMBER"]
      @@supplier = Ecstore::Supplier.where(:member_id=>cookies["MEMBER"].split("-").first,:status=>1).first
    else
      @@supplier = Ecstore::Supplier.find(params[:spplier])
    end

    @@openid = @@supplier.weixin_openid
    @@appid = @@supplier.weixin_appid
    @@appsecret =  @@supplier.weixin_appsecret
=end
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
        render :layout=>'vshop'
      end
    end

    def follower_renew
      openid = params[:openid]
      @follower =  Ecstore::WechatFollower.where(:openid=>openid).first

      supplier = Ecstore::Supplier.find(@follower.supplier_id)
      appid = supplier.weixin_appid
      appsecret =  supplier.weixin_appsecret
      $client ||= WeixinAuthorize::Client.new(appid,appsecret)
      user_info =$client.user(openid).result.to_s
      if user_info.size>2
      @follower.user_info = user_info
      @follower.save
      else
        @follower.destroy
      end
      redirect_to '/admin/wechat/followers'
    end

    def followers_import
      @supplier = Ecstore::Supplier.where(:member_id=>cookies["MEMBER"].split("-").first,:status=>1).first
      appid = @supplier.weixin_appid
      appsecret =  @supplier.weixin_appsecret

      $client ||= WeixinAuthorize::Client.new(appid,appsecret)
     # return render :text=> $client.followers.result
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
      @supplier = Ecstore::Supplier.where(:member_id=>cookies["MEMBER"].split("-").first,:status=>1).first

      if @supplier
        $openid=@supplier.weixin_openid
        $appid = @supplier.weixin_appid
        $appsecret =  @supplier.weixin_appsecret
      else
        return render :text=>'没有微店'
      end
      #$openid='gh_a0e5b9a22803'
      $client ||= WeixinAuthorize::Client.new($appid,$appsecret)
    #  if ($client.is_valid?)
     #   @menu = $client.menu.result['menu']['button']
    #  end
      return render :text=>$client.menu.result
    end

    def menu_edit

      #manco
      $openid='gh_b45eda6a7263'
      @@appid='wx6b00b26294111729'
      @@appsecret='ae953aa0def51bdb7d587f1c2eb66acb'

=begin
      #norsh
      $openid='gh_0033bc7ec157'
      @@appid='wxe531449efd44b06b'
      @@appsecret='6a7cc9336dca96266631512ccb7d2f5a'
=end
      $client ||= WeixinAuthorize::Client.new(@@appid,@@appsecret)

      if ($client.is_valid?)

        menu_manco = '{
     "button":[
     {
          "name":"万家介绍",
          "sub_button":[
          {
                "type":"view",
                "name":"万家简介",
                "url":"http://www.trade-v.com/pages/manco_brand"
            },
            {
                 "type":"view",
                 "name":"服务项目",
                 "url":"http://www.trade-v.com/pages/manco_service"
            },
            {
                 "type":"view",
                 "name":"案例介绍",
                 "url":"http://www.trade-v.com/pages/manco_cases"
            },
            {
                 "type":"view",
                 "name":"渠道招商",
                 "url":"http://www.trade-v.com/pages/manco_partner"
            }
      ]},
      {
           "name":"万家服务",
           "sub_button":[
           {
               "type":"view",
               "name":"运价查询",
               "url":"http://www.trade-v.com/manco/find_manco"
            },
            {
               "type":"view",
               "name":"我要送货",
               "url":"http://www.trade-v.com/manco/find_manco"
            },
            {
               "type":"view",
               "name":"货源小黑板",
               "url":"http://www.trade-v.com/manco/black_good_index"
            },
            {
               "type":"view",
               "name":"车源小黑板",
               "url":"http://www.trade-v.com/manco/black_index"
            },
            {
               "type":"view",
               "name":"优惠券",
               "url":"http://www.trade-v.com/manco"
            }
         ]},
         {
           "name":"关注我们",
           "sub_button":[
           {
               "type":"view",
               "name":"服务网络",
               "url":"http://www.trade-v.com/manco"
            },
            {
               "type":"view",
               "name":"运输跟踪",
               "url":"http://www.trade-v.com/manco/follow"
            },
            {
               "type":"click",
               "name":"我的佣金",
               "key":"SHARE"
            },
            {
               "type":"view",
               "name":"服务点评",
               "url":"http://www.trade-v.com/manco/manco_comment"
            },
           {
               "type":"click",
               "name":"联系我们",
               "key" : "Oauth"
            }]
       }]
 }'

        menu_norsh = '{
     "button":[
     {
          "name":"品牌",
          "sub_button":[
          {
                "type":"view",
                "name":"品牌故事",
                "url":"http://www.trade-v.com/pages/norsh_brand"
            },
            {
                 "type":"view",
                 "name":"渠道招商",
                 "url":"http://www.trade-v.com/pages/norsh_partner"
            },
            {
                 "type":"view",
                 "name":"市场推广",
                 "url":"http://www.trade-v.com/pages/norsh_event"
            },
            {
                 "type":"view",
                 "name":"店长推荐",
                 "url":"http://www.trade-v.com/vshop/97"
            }

      ]},
      {
           "name":"商品",
           "sub_button":[
           {
               "type":"view",
               "name":"宝宝乳牙刷",
               "url":"http://www.trade-v.com/vshop/97/category?cat=515"
            },
            {
               "type":"view",
               "name":"婴童牙膏",
               "url":"http://www.trade-v.com/mproducts?id=a0971002"
            },
            {
               "type":"view",
               "name":"宝宝小软勺",
               "url":"http://www.trade-v.com/mproducts?id=a0971007"
            },
            {
               "type":"view",
               "name":"婴儿手工皂",
               "url":"http://www.trade-v.com/vshop/97/category?cat=572"
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
        menu_tradev = '{
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
        menu=menu_manco
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