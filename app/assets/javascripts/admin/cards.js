//= require jquery.ui.datepicker
//= require jquery.ui.slider
//= require jquery-ui-timepicker-addon
//= require jquery-ui-sliderAccess

$(document).ready(function(){
	// $(".update").live("click",function(){
	// 	$(this).closest("form").find(".toggle").hide();
	// 	$(this).closest("form").find(".toggle.hide").show().css({display:'inline-block'});
	// });
	// $(".cancel").live("click",function(){
	// 	$(this).closest("form").find(".toggle").show();
	// 	$(this).closest("form").find(".toggle.hide").hide();
	// });
	$(".datetime").datetimepicker({
		dateFormat: "yy-mm-dd",
		timeFormat: "hh:mm:ss",
		showSecond: true
	});
	
	$("#ecstore_card_pay_status").bind("change",function(){
		if($(this).val()=="true"){
			$(this).next(".datetime").removeClass("hide");
		}else{
			$(this).next(".datetime").addClass("hide");
			$(".datetime").next(".help").empty();
		}
	});

	$(".edit_form").submit(function(){
		var datetime =  $(".datetime").val();
		if(!$(".datetime").hasClass("hide")&&datetime==''){
			$(".datetime").next(".help").text("请输入支付时间").addClass("error");
			return false;
		}
	});
	
	$("#show_all").live("click",function(){
		$("#import_log_list ul li").show();
		$(this).remove();
	});
	
	$("form.search :submit").bind("click",function(){
		var key = $(this).closest("form").find("input[name='search[key]']").val();
		 if($.trim(key)== ''){
		 	alert("请输入用户名或手机号码");
		 	return false;
		 }
	});

	$("#use_card").live("click",function(){
		// var sms_code = $.trim($("#member_card_sms_code").val());
		// if(sms_code==''){
		// 	$("#member_card_sms_code").next(".help").text("请输入手机验证码").addClass("error");
		// 	return false
		// }

		var card_type = $("#card_type").val();
		if(card_type == "A"){

			var mobile = $("#member_card_user_tel").val();
			var user_tel = $("#user_tel").val();
			if(mobile!=user_tel){
				alert("用卡人手机号码和搜索到的用户手机号码不一致，不能使用此VIP卡 !");
				return false;
			}
		}else{
			var password = $.trim($("#member_card_password").val());
			if(password==''){
				$("#member_card_password").next(".help").text("请输入卡密码").addClass("error");
				return false;
			}
		}
		

		return confirm("确定使用此VIP卡吗？");
	});


	$(".sms-validate").live("change",function(){
		var checked = $(this).attr("checked");
		if(checked == 'checked'){
			$(this).closest(".control-group").next(".control-group").show();
		}else{
			$(this).closest(".control-group").next(".control-group").hide();
		}
	});
	$(".validate-mobile").live("click",function(){
		var mobileInput = $("#member_card_buyer_tel");
		var mobile = $.trim(mobileInput.val());

		if(mobile=='') {
			$(this).next(".help").text("请填写手机号码").addClass("error");
			mobileInput.focus();
			return false;
		}

		if(!/^\d{11}$/.test(mobile)){
			$(this).next(".help").text("请填写11位手机号码").addClass("error");
			mobileInput.focus();
			return false;
		}

		var url = $(this).data("url");
		var method = $(this).data("method");
		var params = { mobile: mobile };
		$.ajax(url,{
			type: method,
			data: params
		});


	});

	$(".pay-now,.pay-later").live("change",function(){
		var checked = $(this).attr("checked");
		if(checked=='checked'&&$(this).hasClass("pay-now")){
			$(this).closest(".control-group").nextAll(".rel-pay").show();
		}else{
			$(this).closest(".control-group").nextAll(".rel-pay").hide();
		}
	});

	$(".validate-by-hand,.validate-by-sms").live("change",function(){
		var checked = $(this).attr("checked");
		if(checked=='checked'&&$(this).hasClass("validate-by-sms")){
			$(this).closest(".control-group").next(".rel-sms").show();
		}else{
			$(this).closest(".control-group").next(".rel-sms").hide();
		}
	});

	// $("#buy_card").live("click",function(){
	// 	var buyer_tel = $("#member_card_buyer_tel").val();
	// });


	$(".send_sms_code").live("click",function(e){
		var input = $("#member_card_buyer_tel");
		if(input.length==0){
			input = $("#member_card_user_tel");
		}

		var tel = $.trim(input.val());
		if(tel=='') {
			input.next(".help").text("请填写手机号码").addClass("error");
			input.focus();
			return false;
		}

		if(!/^\d{11}$/.test(tel)){
			input.next(".help").text("请填写11位手机号码").addClass("error");
			input.focus();
			return false;
		}
		var self = this;
		var url = $(this).data("url");
		var method = $(this).data("method");
		var params = { tel: tel };
		$.ajax(url,{
			type: method,
			data: params,
			success: function(res){
				if(res.code == 't'){
					$(self).next(".help").text("验证码已发送").addClass("sent");
				}else{
					$(self).next(".help").text("验证码发送失败").addClass("error");
				}
			}
		});
	});

	$("#select_all").live("click", function () {
		$(".operate_ids").attr("checked",!!$(this).attr("checked"));
		$(".sel_nums").html($("input.operate_ids:checked").length);
		$(".sel_banner").show();
	});

	$(".sel_all").bind("click",function(){
		$(".sel_nums").html($(".total_card").html());
		$(".sel_banner").attr("all",true);
		$(".sel_operation").val(1);
		return false;
	});

	$(".cancel_all").bind("click",function(){
		$("input:checkbox").attr("checked",false);
		$(".sel_banner").hide();
		$(".sel_banner").removeAttr("all");
		$(".sel_operation").val(0);
		return false;
	});

	$(".dialog").bind("click",function(){
		var url = $(this).data("url");
		var args = ["dialogHeight=200px","dialogWidth=400px","dialogLeft=50%","center=1"].join(";")
		window.showModalDialog(url,args);
	});

	$(".tagd").bind("click",function(){
		var url = $(this).data('url');
		if(!url) return;
		var all = $(".sel_banner").attr("all");
		var cards;
		if(all=='true'){
			cards = "all"
		}else{
			cards = [];
			$("input.operate_ids:checked").each(function(){
				cards.push($(this).val())
			});
		}
		
		$.ajax(url,{
			type: "get",
			data: { cards: cards },
			success:function(res){
				window.location.reload();
			}
		});
	});

	
});