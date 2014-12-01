#encoding : UTF-8
module Admin
  class WechatController < Admin::BaseController

    def menu_edit
      id = params[:id]
      if id ==nil
        return render :text=>"参数错误"
      end
      @supplier = Ecstore::Supplier.find(id)

      @@appid = @supplier.weixin_appid
      @@appsecret = @supplier.weixin_appsecret
      $openid = @supplier.weixin_openid

      $client ||= WeixinAuthorize::Client.new(@@appid,@@appsecret)

     # userinfo = $client.menu#$client.user($openid)
     # return render :text=> "userinfo:"+userinfo.result.to_s


      if ($client.is_valid?)
         response = $client.create_menu(@supplier.menu)
        #response = $client.menu
        render :text=> response.cn_msg
      else
        render :text=>"client valid error"
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
      if params[:id]
        id = params[:id]
        if id ==nil
          return render :text=>"参数错误"
        end
         @supplier = Ecstore::Supplier.find(id)
      else
         @supplier = Ecstore::Supplier.where(:member_id=>cookies["MEMBER"].split("-").first).first
      end

      if @supplier
        $openid=@supplier.weixin_openid
        $appid = @supplier.weixin_appid
        $appsecret =  @supplier.weixin_appsecret
        $client ||= WeixinAuthorize::Client.new($appid,$appsecret)

        return render :text=>$client.menu.result
      else
        return render :text=>'没有微店'
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