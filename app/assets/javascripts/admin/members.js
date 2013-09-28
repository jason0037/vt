$(document).ready(function(){
	$(".sel_reload").change(function(e){
		var status = false;
		if($(this).is(":checked"))
		{
			status = true;
		}
		$.ajax({
		    type: 'post',
		    url:'/admin/members/column_reload',
		    data:{column_id:$(this).val(),col_stat:status},
		    dataType: 'json',
		    success: function(data) {
		      	//alert("sc");
		    }
		});
		window.location.reload();
	});
	$(".operate_all_id").change(function(e){
		var status = false;
		var sel_nums = $(".operate_ids").length;
		if($(this).is(":checked"))
		{
			status = true;
		}
		if(status)
		{
			$(".operate_ids").attr("checked",true);
			$(".sel_nums").html(sel_nums);
			$(".sel_banner").show();
			$(".sms-ids").attr("checked",true);
		

		}else
		{
			$(".operate_ids").attr("checked",false);
			$(".sel_nums").html(0);
			$(".sel_banner").hide();
			$(".sms-ids").attr("checked",false);
			
		}
	});
	$(".operate_ids").change(function(){
		if($(this).attr('checked')=='checked'){
			var id = $(this).val();
			$(".sms-ids[data-id="+id+"]").attr("checked",true);
		}else{
			var id = $(this).val();
			$(".sms-ids[data-id="+id+"]").attr("checked",false);
		}
	});

	$(".cancel_all").live("click", function () {
		$(".operate_ids").attr("checked",false);
		$(".operate_all_id").attr("checked",false);
		$(".sel_nums").html(0);
		$(".sel_banner").hide();
		$(".sel_operation").val(0);
		$("#send_all").val(0)
		return false;
	});
	$(".sel_all").live("click", function () {
		$(".operate_ids").attr("checked",true);
		$(".sel_nums").html($(".total_member").html());
		$(".sel_banner").show();
		$(".sel_operation").val(1);
		$("#send_all").val(1)
		return false;
	});

	$("#sms_editor form").submit(function(){
		$(this).find(":submit").attr('disabled',true).addClass("disabled");
		return true;
	});

	$("#sms_define form").submit(function(){
		if($(this).find("#member_mobiles").val() == ""){
			alert("请先填写手机号码。")
			$(this).find("#member_mobiles").focus();
			return false;
		}

		if($(this).find("#member_text").val()==""){

			alert("请填写短信内容。")
			$(this).find("#member_text").val().focus();
			return false;
		}
		$(this).find(":submit").attr('disabled',true).addClass("disabled");
		return true;
	});

});