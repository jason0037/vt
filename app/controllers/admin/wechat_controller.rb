#encoding : UTF-8
module Admin
  class WechatController < Admin::BaseController
=begin
    if cookies["MEMBER"]
      @@supplier = Ecstore::Supplier.where(:member_id=>cookies["MEMBER"].split("-").first).first
    else
      @@supplier = Ecstore::Supplier.find(params[:spplier])
    end

    @@openid = @@supplier.weixin_openid
    @@appid = @@supplier.weixin_appid
    @@appsecret =  @@supplier.weixin_appsecret
=end

    def menu_edit_back
      id = params[:id]
      if id ==nil
        return render :text=>"参数错误"
      end
      @supplier = Ecstore::Supplier.find(id)

      appid = @supplier.weixin_appid
      appsecret = @supplier.weixin_appsecret

      $client ||= WeixinAuthorize::Client.new(appid,appsecret)

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
               "url":"http://www.trade-v.com/mproducts?id=a0971002&supplier_id=97"
            },
            {
               "type":"view",
               "name":"宝宝小软勺",
               "url":"http://www.trade-v.com/mproducts?id=a0971007&supplier_id=97"
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
               "url":"http://www.trade-v.com/goods?platform=mobile&supplier_id=97"
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
               "url":"http://www.trade-v.com/mgallery?name=%E5%A5%B6%E9%85%AA&id=78"
            },
            {
               "type":"view",
               "name":"酒类",
               "url":"http://www.trade-v.com/mgallery?name=%E9%85%92%E7%B1%BB&id=78"
            },
            {
               "type":"view",
               "name":"零食",
               "url":"http://www.trade-v.com/mgallery?name=%E9%9B%B6%E9%A3%9F&id=78"
            },
            {
               "type":"view",
               "name":"婴童",
               "url":"http://www.trade-v.com/mgallery?name=%E5%A9%B4%E7%AB%A5&id=78"
            }]
         },
         {
           "name":"我的订单",
           "sub_button":[
           {
               "type":"view",
               "name":"我的订单",
               "url":"http://www.trade-v.com/goods?platform=mobile&supplier_id=78"
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
        if @supplier.id==78
          menu = menu_tradev
        elsif @supplier.id==97
          menu = menu_norsh
        elsif @supplier.id==98
          menu = menu_manco
        end

        #"url":"https://open.weixin.qq.com/connect/oauth2/authorize?appid=wxec23a03bf5422635&redirect_uri=http%3A%2F%2Fwww.trade-v.com%2Fauth%2Fweixin%2Fcallback&response_type=code&scope=snsapi_base&state=STATE#wechat_redirect"
        #"url":"https://open.weixin.qq.com/connect/oauth2/authorize?appid=wxec23a03bf5422635&redirect_uri=http%3A%2F%2Fwww.trade-v.com%2Fauth%2Fweixin%2Fcallback&response_type=code&scope=snsapi_base&state=STATE#wechat_redirect"
        response = $client.create_menu(menu)
        #response = $client.menu
        render :text=> response.cn_msg#.result#response.en_msg#user_info# @followers #JSON.parse(@user_info)
      end
    end

    def menu_edit
      id = params[:id]
      if id ==nil
        return render :text=>"参数错误"
      end
      @supplier = Ecstore::Supplier.find(id)

      appid = @supplier.weixin_appid
      appsecret = @supplier.weixin_appsecret

      $client ||= WeixinAuthorize::Client.new(appid,appsecret)

      if ($client.is_valid?)
        #"url":"https://open.weixin.qq.com/connect/oauth2/authorize?appid=wxec23a03bf5422635&redirect_uri=http%3A%2F%2Fwww.trade-v.com%2Fauth%2Fweixin%2Fcallback&response_type=code&scope=snsapi_base&state=STATE#wechat_redirect"
        #"url":"https://open.weixin.qq.com/connect/oauth2/authorize?appid=wxec23a03bf5422635&redirect_uri=http%3A%2F%2Fwww.trade-v.com%2Fauth%2Fweixin%2Fcallback&response_type=code&scope=snsapi_base&state=STATE#wechat_redirect"
        response = $client.create_menu(@supplier.menu)
        #response = $client.menu
        render :text=> response.cn_msg#.result#response.en_msg#user_info# @followers #JSON.parse(@user_info)
      end
    end

    def followers
      # @order_all = Ecstore::Order.where(:recommend_user=>wechat_user).select("sum(commission) as share").group(:recommend_user).first
     #sql ='SELECT openid,user_info,(select sum(commission) from mdk.sdb_b2c_orders where recommend_user= mdk.sdb_wechat_followers.openid group by recommend_user)  as commission FROM mdk.sdb_wechat_followers'
      if cookies["MEMBER"]
        @supplier = Ecstore::Supplier.where(:member_id=>cookies["MEMBER"].split("-").first).first
        if @supplier == nil
          return render :text=>'您还没有关注者',:layout=>'vshop'
        else
          @followers = Ecstore::WechatFollower.where(:supplier_id=>@supplier.id).paginate(:page => params[:page], :per_page => 20).order("commission DESC")
        end
        layout = 'vshop'
      elsif current_admin
        @followers = Ecstore::WechatFollower.all.paginate(:page => params[:page], :per_page => 20).order("commission DESC")
        layout = "admin"
      else
        redirect_to  '/vshop/login'
      end

      #更新佣金
      @followers.each do |follower|
        sql ="update mdk.sdb_wechat_followers set commission= (select sum(commission) from mdk.sdb_b2c_orders where recommend_user= '#{follower.openid}' group by recommend_user) where openid='#{follower.openid}'"
        ActiveRecord::Base.connection.execute(sql)
      end
      #@order_all = Ecstore::Order.where(:recommend_user=>wechat_user).select("sum(commission) as share").group(:recommend_user).first

       render :layout=>layout

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
      @supplier = Ecstore::Supplier.where(:member_id=>cookies["MEMBER"].split("-").first).first
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
      @supplier = Ecstore::Supplier.where(:member_id=>cookies["MEMBER"].split("-").first).first

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