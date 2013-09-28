$(document).ready(function(){
	$("#send_sms_code").live("click",function(){
		if($(this).hasClass("disabled")){
			return;
		}
		
		var self  = this;

		var tip = $(".sms_tip");
		var url = $(this).data("url");
		var tel = $(".sms_tel").val();
		var params = { tel: tel };
		$.ajax(url,{
			type: "GET",
			data: params,
			success: function(res){
				if(res.code == 't'){
					$(self).addClass("disabled");
					tip.html("<span id='count_sec'>60</span>秒后可重新发送验证码");
					var d = 60;
					var timer = window.setInterval(function(){
						d = d - 1;
						if( d < 0 ){
							$(self).removeClass("disabled");
							tip.empty();
							clearInterval(timer);
						}else{
							$("#count_sec").text(d);
						}
					},1000);
				}else{
					tip.text("发送验证码失败");
				}
			}
		});
	});
});