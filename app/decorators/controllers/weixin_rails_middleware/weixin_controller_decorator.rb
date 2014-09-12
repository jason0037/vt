# encoding: utf-8
# 1, @weixin_message: 获取微信所有参数.
# 2, @weixin_public_account: 如果配置了public_account_class选项,则会返回当前实例,否则返回nil.
# 3, @keyword: 目前微信只有这三种情况存在关键字: 文本消息, 事件推送, 接收语音识别结果
WeixinRailsMiddleware::WeixinController.class_eval do

  def reply
    case @keyword
      when '买'
        render xml: send("response_news_message",{})
      when '地址'
        render xml: send("response_location_message", {})
      when '奶酪'
        render xml: send("response_news_message",{})
      when '黄油'
        render xml: send("response_news_message",{})
      when '大渔'
        render xml: send("response_news_message",{})
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
        pic_url="http://www.trade-v.com/images/a0#{id}/homepage/getqrcode_h.jpg"
        link_url="http://www.trade-v.com/images/a0#{id}/homepage/getqrcode.jpg"

        title1="关于我们"
        desc1 =""
        pic_url1="http://www.trade-v.com/images/a0#{id}/homepage/logo.jpg"
        link_url1="http://www.trade-v.com/pages/#{@weixin_public_account.url}_aboutus"

        # redirect_uri="http%3a%2f%2fwww.trade-v.com%2fauth%2fweixin%2fcallback"

        title2="微信直通"
        desc2 =""
        pic_url2="http://www.trade-v.com/assets/vshop/Oauth_s.png"
        link_url2= "https://open.weixin.qq.com/connect/oauth2/authorize?appid=#{appid}&5&redirect_uri=http%3a%2f%2fwww.trade-v.com%2fauth%2fweixin%2f#{id}%2fcallback&response_type=code&scope=snsapi_base&state=STATE#wechat_redirect"

        articles = [generate_article(title, desc, pic_url, link_url),generate_article(title1, desc1, pic_url1, link_url1),generate_article(title2, desc2, pic_url2, link_url2)]
        reply_news_message(articles)

      when '黄油'
        title="[总统 PRESIDENT]超高温灭菌稀奶油 200毫升仅售¥22.4元"
        desc ="法国进口的总统谈奶油，是从牛奶中提炼出来的纯天然食品，一般乳脂含量为16.5%，营养价值高，入口即化"
        pic_url="http://www.trade-v.com/images/a074/a0742048_m.jpg"
        link_url="http://www.trade-v.com/mproducts?id=a0742048&from=weixin&wechatuser=#{user}&supplier_id=#{id}"

        articles = [generate_article(title, desc, pic_url, link_url)]
        reply_news_message(articles)
      when '大渔'
        title="[大渔]海鲜铁板烧"
        desc =""
        pic_url="http://www.trade-v.com/assets/vshop/dayu.jpg"
        link_url="http://www.trade-v.com/tairyo"
        articles = [generate_article(title, desc, pic_url, link_url)]
        reply_news_message(articles)
      when '奶酪'
        title="[总统 PRESIDENT]安文达切丝奶酪70克 仅售¥20.5元"
        desc ="每公斤奶酪都是有10公斤的牛奶浓缩而成，含有丰富的蛋白质、钙、脂肪、钠和维生素等营养成分。70克*24/箱 产地:法国"
        pic_url="http://www.trade-v.com/images/a074/a0741022_m.jpg"
        link_url="http://www.trade-v.com/mproducts?id=a0741022&from=weixin&wechatuser=#{user}&supplier_id=#{id}"

        articles = [generate_article(title, desc, pic_url, link_url)]
        reply_news_message(articles)
      when 'share'
        share = 0
        @order = Ecstore::Order.where(:recommend_user=>@weixin_message.FromUserName).select("sum(commission) as share").group(:recommend_user).first
        if @order
          share =@order.share.round(2)
        end

        title="您的总佣金收益是: #{share}元"
        desc ="查看佣金详情请点击"
        pic_url='http://www.trade-v.com/assets/vshop/commission_banner.jpg'
        link_url="http://www.trade-v.com/share?FromUserName=#{user}&supplier_id=#{id}"
        articles = [generate_article(title, desc, pic_url, link_url)]
        reply_news_message(articles)
      when 'subscribe'
        title="您好，#{@weixin_public_account.name}欢迎您"
        desc ="#{@weixin_public_account.desc}"
        pic_url="http://www.trade-v.com/images/a0#{id}/homepage/post.jpg"
        link_url="http://www.trade-v.com/vshop/#{id}"
        articles = [generate_article(title, desc, pic_url, link_url)]
        reply_news_message(articles)
      else
        title="[紫薇]牛奶/起司棒饼干仅售 35.10元"
        desc ="[紫薇]牛奶/起司棒饼干 500克 产地:台湾"
        pic_url="http://www.trade-v.com/images/a076/a0761003_m.jpg"
        link_url="http://www.trade-v.com/mproducts?id=a0751003&from=weixin&user=#{user}&supplier_id=#{id}"

        title1="[叶客]小叶苦丁茶仅售 50.00元"
        desc1 ="保质期：365   包装种类: 罐装   产地: 中国大陆  是否含糖: 无糖   配料表：小叶苦丁"
        pic_url1="http://www.trade-v.com/images/a075/a0751003_m.jpg"
        link_url1="http://www.trade-v.com/mproducts?id=a0751003&from=weixin&wechatuser=#{user}&supplier_id=#{id}"

        articles = [generate_article(title, desc, pic_url, link_url),generate_article(title1, desc1, pic_url1, link_url1)]
        reply_news_message(articles)
    end

  end

  def response_text_message(options={})
    #reply_text_message("Your Message: #{@keyword}")
    case @keyword
      when 'share'
      share = 0
        @order = Ecstore::Order.where(:wechat_recommend=>@weixin_message.FromUserName).select("SUM(final_amount)*0.01 as share").group(:wechat_recommend).first
        if @order
          share =@order.share.round(2)
        end
        message="您好！,您可以领取的佣金是：￥#{share}元"
      else
        message="您好！#{@weixin_public_account.name}欢迎您！"
    end

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
    reply_text_message("您现在的位置是: #{@lx}, #{@ly}, #{@scale}, #{@label}")
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
    reply_text_message("回复链接信息")

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
    reply_text_message("回复视频信息")
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
      return reply_text_message("扫描带参数二维码事件: 1. 用户未关注时，进行关注后的事件推送, keyword: #{@keyword}")
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
    reply_text_message("扫描带参数二维码事件: 2. 用户已关注时的事件推送, keyword: #{@keyword}")
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
      when 'ON_SALE'
        @keyword='奶酪'
        response_news_message({})
      when 'NEW'
        @keyword='黄油'
        response_news_message({})
      when 'SHARE'
        @keyword='share'
        response_news_message({})
      when 'Oauth'
        @keyword='授权'
        response_news_message({})
      else
       # reply_text_message("你点击了: #{@keyword}")
    end
  end

  # 点击菜单跳转链接时的事件推送
  def handle_view_event
    Rails.logger.info("你点击了: #{@keyword}")
    reply_text_message("你点击了: #{@keyword}")
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
