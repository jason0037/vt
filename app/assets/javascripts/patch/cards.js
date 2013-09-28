//=require sms
$(document).ready(function(){
	$("#update_tel_form").submit(function(){
		var exception =  false;

		var sms_code = $.trim($("#sms_code").val());
		if(sms_code.length == 0){
			$("#sms_code").next(".msg").addClass("help-block").text("请输入验证码");
			exception =  true
		}else{
			$("#sms_code").next(".msg").removeClass("help-block").empty();
		}

		var tel = $.trim($(".new-tel").val());
		if(tel.length == 0){
			$(".new-tel").next(".msg").addClass("help-block").text("请输入手机号码");
			exception =  true;
		}else if(tel.length > 0 && !/^[1-9][0-9]{10}$/.test(tel)){
			$(".new-tel").next(".msg").addClass("help-block").text("手机号码是11位数字,请重新填写");
			exception =  true;
		}else{
			$(".new-tel").next(".msg").removeClass("help-block").empty();
		}
		if(exception){
			return false;
		}
	});
});