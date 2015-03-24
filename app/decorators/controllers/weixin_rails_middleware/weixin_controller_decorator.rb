# encoding: utf-8
# 1, @weixin_message: 获取微信所有参数.
# 2, @weixin_public_account: 如果配置了public_account_class选项,则会返回当前实例,否则返回nil.
# 3, @keyword: 目前微信只有这三种情况存在关键字: 文本消息, 事件推送, 接收语音识别结果
WeixinRailsMiddleware::WeixinController.class_eval do

  def reply
    case @keyword
      when '地址'
        render xml: send("response_location_message", {})
      when '1'
        render xml: send("response_news_message", {})
      when '11'
        render xml: send("response_news_message", {})
      when '2'
        render xml: send("response_news_message", {})
      when '3'
        render xml: send("response_news_message", {})
      when '测试'
        render xml: send("response_news_message", {})
      when '买'
        render xml: send("response_news_message", {})
      when '4'
        render xml: send("response_news_message", {})
      when '5'
        render xml: send("response_news_message", {})
      when '登录'
        render xml: send("response_news_message", {})
      else
       render xml: send("response_#{@weixin_message.MsgType}_message", {})
    end

  end

  private

  def response_news_message(options={})
    id = @weixin_public_account.id
    appid = @weixin_public_account.weixin_appid
    user = @weixin_message.FromUserName
    #user = @weixin_message.ToUserName
    case @keyword


      when '授权'

        title="二维码"
        desc =""
        pic_url="http://vshop.trade-v.com/images/a0#{id}/homepage/getqrcode_h.jpg"
        link_url="http://vshop.trade-v.com/images/a0#{id}/homepage/getqrcode.jpg"

        title1="关于我们"
        desc1 =""
        pic_url1="http://vshop.trade-v.com/images/a0#{id}/homepage/logo.jpg"
        link_url1="http://vshop.trade-v.com/pages/#{@weixin_public_account.url}_aboutus"


        if id==98
          title2="技术支持--贸威O2O微信直销商城"
          desc2 =""
          pic_url2="http://vshop.trade-v.com/images/a078/homepage/logo.jpg"
          link_url2="http://vshop.trade-v.com/world_food?supplier_id=78"
          articles = [generate_article(title, desc, pic_url, link_url),generate_article(title1, desc1, pic_url1, link_url1),generate_article(title2, desc2, pic_url2, link_url2)]

        else
          articles = [generate_article(title, desc, pic_url, link_url),generate_article(title1, desc1, pic_url1, link_url1)]


        end

      when '买'
        title="[测试商品]-----------------"
        desc ="测试商品0.01元，佣金3.00元"
        pic_url="http://vshop.trade-v.com/images/a072/a0729002_b_1.jpg"
        link_url="http://vshop.trade-v.com/mproducts?id=a980000&fp=mproducts&supplier_id=#{id}"
        articles = [generate_article(title, desc, pic_url, link_url)]

      when '11'
        title="团购"
        desc ="团购"
        pic_url="http://vshop.trade-v.com/images/a078/homepage/tuan_2015.jpg"
        link_url="http://vshop.trade-v.com/tuan"
        articles = [generate_article(title, desc, pic_url, link_url)]

      when '通知'
        title="非常抱歉！！"
        desc ="您点击的商品馆正在筹备上线，敬请期待"
        pic_url=""
        link_url="http://vshop.trade-v.com/vshop/notice?supplier_id=#{id}"
        articles = [generate_article(title, desc, pic_url, link_url)]

      when '登录'
        title="自动登录测试"
        desc =""
        pic_url=""
        link_url="http://vshop.trade-v.com/autologin1?id=#{id}"
        articles = [generate_article(title, desc, pic_url, link_url)]



      when '1'
        title="我的自媒体店铺"
        desc=""
        pic_url="http://vshop.trade-v.com/images/a078/homepage/zimaoqu.jpg"
        link_url="http://vshop.trade-v.com/shop/shopinfos"
        articles = [generate_article(title, desc, pic_url, link_url)]

      when '2'
        # title="吃货帮聚会报名"
        # desc=""
        # pic_url="http://vshop.trade-v.com/assets/foodie.jpg"
        # link_url="http://vshop.trade-v.com/events/foodie?supplier_id=78"
        # articles = [generate_article(title, desc, pic_url, link_url)]
         # desc ="回复1:进入贸威自媒体商场 ,回复2:吃货平台活动中心"
         title ="欢迎关注贸威优品商城"
        desc = "寓客衡山北郊德国文化月来了！
上海寓客文化联合顾村公园、上海衡山北郊宾馆，于2015年3月18日至4月15日，举办为期近一个月的德国文化月活动。
这是一场活色生香的文化狂欢，网罗了德国最纯正的啤酒、美食、音乐、旅游、运动，让你身临其境地感受德国文化和休闲文化，最短时间了解德国，爱上德国。"
        pic_url="http://vshop.trade-v.com/images/gucunsausage5.jpg"
        link_url = "http://vshop.trade-v.com/galleries/126"
       # link_url="http://mp.weixin.qq.com/s?__biz=MzA4ODMwODE2MA==&mid=203230430&idx=1&sn=a8d2c5b5870c824d0cd2cc3353c8c746&scene=1&from=singlemessage&isappinstalled=0#rd"

          # title1="贸威除了热卖中的正宗德国香肠、卓玛泉、温县铁棍山药等优质产品外，还有每天听音乐、做按摩、睡软床、吹风扇、吃熟食的神秘来客，这就是雪龙黑牛，顶级品质，与您分享！"
          # desc1 =""
          # pic_url1=""
          # link_url1="http://mp.weixin.qq.com/s?__biz=MzA5OTM5ODIzMQ==&mid=204081654&idx=1&sn=f3430887159032c774ef6f647b9162aa#rd"
          #  articles = [generate_article(title, desc, pic_url, link_url),generate_article(title1, desc1, pic_url1, link_url1)]
        articles = [generate_article(title, desc, pic_url, link_url)]


      when 'on_sale'
        title="法兰克福香肠350克/ Frankfurter Sausages 350g仅售¥44元"
        desc =""
        pic_url="http://vshop.trade-v.com/images/a077/a0771030_m.jpg"
        link_url="http://vshop.trade-v.com/mproducts?id=a0771030&from=weixin&wechatuser=#{user}&supplier_id=#{id}"
        articles = [generate_article(title, desc, pic_url, link_url)]

      when 'crab'
        title="一大波螃蟹正在接近-天山蟹客"
        desc ="由于新疆湖面温度已到达零下六度，今年暂停供应天山大闸蟹，同时非常感谢今年亲们的大力支持，明年会推出更多更棒的活动，敬请期待，明年再见！"
        pic_url="http://vshop.trade-v.com/images/a087/crap.jpg"
        link_url="http://vshop.trade-v.com/mgallery?name=%E5%A4%A9%E5%B1%B1%E5%A4%A7%E9%97%B8%E8%9F%B9&id=#{id}&supplier_id=#{id}&from=weixin&wechatuser=#{user}"
        articles = [generate_article(title, desc, pic_url, link_url)]

      when 'new'
        title="冰鲜松茸7cm-9cm【香格里拉海拔3500米以上的珍宝】"
        desc =""
        pic_url="http://vshop.trade-v.com/images/a0112/a01120003_m.jpg"
        link_url="http://vshop.trade-v.com/mgallery?name=%E5%86%B0%E9%B2%9C%E6%9D%BE%E8%8C%B8&id=#{id}&from=weixin&wechatuser=#{user}&supplier_id=#{id}"
        articles = [generate_article(title, desc, pic_url, link_url)]
      when '测试'
        title="[测试商品]-----------------"
        desc ="测试商品0.01元，佣金3.00元"
        pic_url="http://vshop.trade-v.com/images/a072/a0729002_b_1.jpg"
        link_url="http://vshop.trade-v.com/mproducts?id=a980000&fp=mproducts&supplier_id=#{id}&from=weixin&wechatuser=#{user}"
        articles = [generate_article(title, desc, pic_url, link_url)]

      when 'share'
        share = 0
        @order = Ecstore::Order.where(:recommend_user=>@weixin_message.FromUserName,:pay_status=>'1').select("sum(commission) as share").group(:recommend_user).first
        if @order
          share =@order.share.round(2)
        end

        title="您的总佣金收益是: #{share}元"
        desc ="查看佣金详情请点击"
        pic_url='http://vshop.trade-v.com/assets/vshop/commission_banner.jpg'
        link_url="http://vshop.trade-v.com/share?FromUserName=#{user}&supplier_id=#{id}"

        title1="如何轻松赚佣金"
        desc1 =""
        pic_url1="https://mmbiz.qlogo.cn/mmbiz/oMwR6HEEzCy0xJicVicrfc9sEyMlj1M8ytz5UsZFiaF3H28CMq2g0nyiaRyJibjcJic3iaVypnia6vCXKicCQnz3QOGyITA/0"
        link_url1="http://mp.weixin.qq.com/s?__biz=MzA5OTM5ODIzMQ==&mid=203023353&idx=1&sn=f9cf0b0b53d70ec67126a6ab93a7ed9a#rd"

        articles = [generate_article(title, desc, pic_url, link_url),generate_article(title1, desc1, pic_url1, link_url1)]
      when 'subscribe'
        if id == 78
        #  title="欢迎关注贸威优品商城"
        # # desc ="回复1:进入贸威自媒体商场 ,回复2:吃货平台活动中心"
        # desc = ""
        # pic_url="http://vshop.trade-v.com/images/gucunsausage.jpg"
        # link_url=""
         title ="欢迎关注贸威优品商城"
        desc = "寓客衡山北郊德国文化月来了！
上海寓客文化联合顾村公园、上海衡山北郊宾馆，于2015年3月18日至4月15日，举办为期近一个月的德国文化月活动。
这是一场活色生香的文化狂欢，网罗了德国最纯正的啤酒、美食、音乐、旅游、运动，让你身临其境地感受德国文化和休闲文化，最短时间了解德国，爱上德国。"
        pic_url="http://vshop.trade-v.com/images/gucunsausage5.jpg"
        link_url = "http://vshop.trade-v.com/topics/2015sakura?platform=mobile"
       # link_url="http://mp.weixin.qq.com/s?__biz=MzA4ODMwODE2MA==&mid=203230430&idx=1&sn=a8d2c5b5870c824d0cd2cc3353c8c746&scene=1&from=singlemessage&isappinstalled=0#rd"

          # title1="贸威除了热卖中的正宗德国香肠、卓玛泉、温县铁棍山药等优质产品外，还有每天听音乐、做按摩、睡软床、吹风扇、吃熟食的神秘来客，这就是雪龙黑牛，顶级品质，与您分享！"
          # desc1 =""
          # pic_url1=""
          # link_url1="http://mp.weixin.qq.com/s?__biz=MzA5OTM5ODIzMQ==&mid=204081654&idx=1&sn=f3430887159032c774ef6f647b9162aa#rd"
          #  articles = [generate_article(title, desc, pic_url, link_url),generate_article(title1, desc1, pic_url1, link_url1)]
        articles = [generate_article(title, desc, pic_url, link_url)]
        else

          title="您好，#{@weixin_public_account.name}欢迎您"
          desc ="#{@weixin_public_account.desc}"
          pic_url="http://vshop.trade-v.com/images/a0#{id}/homepage/post.jpg"
          link_url="http://vshop.trade-v.com/vshop/#{id}"
          articles = [generate_article(title, desc, pic_url, link_url)]
        end
      when '5'
        if id ==97
          title="诺狮产品店长推荐"
          desc =""
          pic_url="http://vshop.trade-v.com/images/a0#{id}/homepage/post.jpg"
          link_url="http://vshop.trade-v.com/vshop/#{id}"
          articles = [generate_article(title, desc, pic_url, link_url)]
        end
      when '4'
        if id ==97
          title="领取分享谢礼"
          desc =""
          pic_url="https://mmbiz.qlogo.cn/mmbiz/oMwR6HEEzCy0xJicVicrfc9sEyMlj1M8ytz5UsZFiaF3H28CMq2g0nyiaRyJibjcJic3iaVypnia6vCXKicCQnz3QOGyITA/0"
          link_url="http://mp.weixin.qq.com/s?__biz=MzA3NzQ0MjMzNQ==&mid=200440674&idx=1&sn=891b3876611926ba115678e685983ba3#rd"
          articles = [generate_article(title, desc, pic_url, link_url)]
        end
      when '3'
        if id ==97
          title="了解诺狮品牌故事"
          desc =""
          pic_url="http://vshop.trade-v.com/images/a0#{id}/homepage/logo.jpg"
          link_url="http://vshop.trade-v.com/pages/norsh_brand"
          articles = [generate_article(title, desc, pic_url, link_url)]
        end
      else
        if id ==97
          desc ="回复01—进入“诺狮产品店长推荐”；回复02—领取分享谢礼；回复03—了解诺狮品牌故事"
        else
          desc =""
        end
        title="您好，我们将尽快回复您的问题"
        pic_url="http://vshop.trade-v.com/images/a0#{id}/homepage/logo.jpg"
        link_url="http://vshop.trade-v.com/vshop/#{id}"
        articles = [generate_article(title, desc, pic_url, link_url)]
    end
    if articles
      reply_news_message(articles)
    end
  end

  def response_text_message(options={})
    #reply_text_message("Your Message: #{@keyword}")

    message="您好！#{@weixin_public_account.name}欢迎您！"
    reply_text_message(message)
  end

  # <Location_X>23.134521</Location_X>
  # <Location_Y>113.358803</Location_Y>
  # <Scale>20</Scale>
  # <Label><![CDATA[位置信息]]></Label>
  def response_location_message(options={})
    @lx    = @weixin_message.Location_X
    @ly    = @weixin_message.Location_Y
    @scale = @weixin_message.Scale
    @label = @weixin_message.Label
    #   reply_text_message("您现在的位置是: #{@lx}, #{@ly}, #{@scale}, #{@label}")
  end

  # <PicUrl><![CDATA[this is a url]]></PicUrl>
  # <MediaId><![CDATA[media_id]]></MediaId>
  def response_image_message(options={})
    @media_id = @weixin_message.MediaId # 可以调用多媒体文件下载接口拉取数据。
    @pic_url  = @weixin_message.PicUrl  # 也可以直接通过此链接下载图片, 建议使用carrierwave.
    reply_image_message(generate_image(@media_id))
  end

  # <Title><![CDATA[公众平台官网链接]]></Title>
  # <Description><![CDATA[公众平台官网链接]]></Description>
  # <Url><![CDATA[url]]></Url>
  def response_link_message(options={})
    @title = @weixin_message.Title
    @desc  = @weixin_message.Description
    @url   = @weixin_message.Url
#    reply_text_message("回复链接信息")

  end

  # <MediaId><![CDATA[media_id]]></MediaId>
  # <Format><![CDATA[Format]]></Format>
  def response_voice_message(options={})
    @media_id = @weixin_message.MediaId # 可以调用多媒体文件下载接口拉取数据。
    @format   = @weixin_message.Format
    # 如果开启了语音翻译功能，@keyword则为翻译的结果
    # reply_text_message("回复语音信息: #{@keyword}")
    reply_voice_message(generate_voice(@media_id))
  end

  # <MediaId><![CDATA[media_id]]></MediaId>
  # <ThumbMediaId><![CDATA[thumb_media_id]]></ThumbMediaId>
  def response_video_message(options={})
    @media_id = @weixin_message.MediaId # 可以调用多媒体文件下载接口拉取数据。
    # 视频消息缩略图的媒体id，可以调用多媒体文件下载接口拉取数据。
    @thumb_media_id = @weixin_message.ThumbMediaId
    #  reply_text_message("回复视频信息")
  end

  def response_event_message(options={})
    event_type = @weixin_message.Event
    send("handle_#{event_type.downcase}_event")
  end


  private

  # 关注公众账号
  def handle_subscribe_event
    if @keyword.present?
      # 扫描带参数二维码事件: 1. 用户未关注时，进行关注后的事件推送
      #  return reply_text_message("扫描带参数二维码事件: 1. 用户未关注时，进行关注后的事件推送, keyword: #{@keyword}")
    end
    reply_text_message("感谢您关注#{@weixin_public_account.name}")
    @keyword = "subscribe"
    response_news_message()
  end

  # 取消关注
  def handle_unsubscribe_event
    Rails.logger.info("#{@weixin_message.FromUserName} 取消关注")
  end

  # 扫描带参数二维码事件: 2. 用户已关注时的事件推送
  def handle_scan_event
    # reply_text_message("扫描带参数二维码事件: 2. 用户已关注时的事件推送, keyword: #{@keyword}")
  end

  def handle_location_event # 上报地理位置事件
    @lat = @weixin_message.Latitude
    @lgt = @weixin_message.Longitude
    @precision = @weixin_message.Precision
    # reply_text_message("Your Location: #{@lat}, #{@lgt}, #{@precision}")
  end

  # 点击菜单拉取消息时的事件推送
  def handle_click_event

    case @keyword
      when 'CRAB'
        @keyword='crab'
        response_news_message({})
      when 'ON_SALE'
        @keyword='on_sale'
        response_news_message({})
      when 'NEW'
        @keyword='new'
        response_news_message({})
      when 'SHARE'
        @keyword='share'
        response_news_message({})
      when 'Oauth'
        @keyword='授权'
        response_news_message({})
      when 'Notice'
        @keyword='通知'
        response_news_message({})

      else
        # reply_text_message("你点击了: #{@keyword}")
    end
  end

  # 点击菜单跳转链接时的事件推送
  def handle_view_event
    Rails.logger.info("你点击了: #{@keyword}")
    #  reply_text_message("你点击了: #{@keyword}")
    session[:wechat_user]= @weixin_message.FromUserName
  end

  # 帮助文档: https://github.com/lanrion/weixin_authorize/issues/22

  # 由于群发任务提交后，群发任务可能在一定时间后才完成，因此，群发接口调用时，仅会给出群发任务是否提交成功的提示，若群发任务提交成功，则在群发任务结束时，会向开发者在公众平台填写的开发者URL（callback URL）推送事件。

  # 推送的XML结构如下（发送成功时）：

  # <xml>
  # <ToUserName><![CDATA[gh_3e8adccde292]]></ToUserName>
  # <FromUserName><![CDATA[oR5Gjjl_eiZoUpGozMo7dbBJ362A]]></FromUserName>
  # <CreateTime>1394524295</CreateTime>
  # <MsgType><![CDATA[event]]></MsgType>
  # <Event><![CDATA[MASSSENDJOBFINISH]]></Event>
  # <MsgID>1988</MsgID>
  # <Status><![CDATA[sendsuccess]]></Status>
  # <TotalCount>100</TotalCount>
  # <FilterCount>80</FilterCount>
  # <SentCount>75</SentCount>
  # <ErrorCount>5</ErrorCount>
  # </xml>
  def handle_masssendjobfinish_event
    Rails.logger.info("回调事件处理")
  end

end
