//=require sms
$(document).ready(function(){
	$("input[name='activate_type']").bind("change",function(){
		var _type = $(this).val();
		if(_type == 'card_no'){
			$("form.card_no").show();
			$("form.user_tel").hide();
		}else{
			$("form.card_no").hide();
			$("form.user_tel").show();
		}
	});

	$(".confirm-form").submit(function(){
		var tel = $.trim($(".tel").val());
		if(tel.length == 0){
			$(".tel").focus().next(".error").text("请输入手机号码");
			return false;
		}else if (!/^[1-9][0-9]{10}$/.test(tel)){
			$(".tel").focus().next(".error").text("手机号码格式错误,请重新输入");
			return false;
		}else{
			return true;
		}


	});

	$("#select_card").submit(function(){
		if($(this).find(":checked").length==0){
			$(this).find(".error").text("请选择需要激活的VIP卡");
			return false;
		}else{
			$(this).find(".error").empty();
		}	
	});

	
});