//=require area_seletor
//= require bootstrap-modal

$(document).ready(function(){
	$("#delivery_logi_id").change(function(){
		$("#delivery_logi_name").val($(this).find("option:selected").text());
	});
  	
  	$("#reship_logi_id").change(function(){
  		$("#reship_logi_name").val($(this).find("option:selected").text());
  	});

  	$("#refund_pay_app_id").change(function(){
  		$("#refund_pay_name").val($(this).find("option:selected").text());
  	});

  	$(".pagination").on("click", "a",function(){
  		var url  = $(this).attr("href");
  		$.getScript(url,function(){
  			$("#select_page").attr("checked",false);
  			$("#batch_inputs input").each(function(){
  				var orderId = $(this).val();
  				$("#orders input[value='"+orderId+"']").attr("checked",true).trigger('change');
  			});
  		});
  		return false;
  	});

  	var countSelection = function(){
  		$("#count").text($("#batch_inputs input").length);
  	};

  	var getOrderIds = function(){
  		var ids = []
  		$("#batch_inputs input").each(function(){
			ids.push($(this).val());
		});

  		return ids;
  	};

  	$("#orders").on("change","#select_page",function(){
  		$("#orders input.order:checkbox").attr("checked",$(this).attr("checked")=="checked").trigger("change");
  	});
  	$("#orders").on("change","input.order:checkbox",function(){
  		if($(this).attr("checked")=="checked"){
  			$(this).closest("tr").addClass('selected');
  			if($("#batch_inputs input[value='"+$(this).val()+"']").length==0)
  				$("#batch_inputs").append($(this).clone());
  		}else{
  			$(this).closest("tr").removeClass('selected');
  			$("#batch_inputs input[value='"+$(this).val()+"']").remove();
  		}
  		countSelection();
  	});
  	$("#select_all").click(function(){
  		var orderIds = $("#orders").attr("order_ids").split(",");
  		$.each(orderIds,function(index,val){
  			if($("#batch_inputs input[value='"+val+"']").length==0)
  			   $("#batch_inputs").append('<input class="order" id="check_'+val+'" type="checkbox" value="'+val+'" checked="checked">');
  		});
  		$("#orders input.order:checkbox").attr("checked",true).trigger("change");
  	});

  	$("#cancel_all").click(function(){
  	     $("#batch_inputs").empty();
  	     $("#orders input.order:checkbox").attr("checked",false).trigger("change");
  	});



  	

  	$("#pop_tegs").click(function(){
		$("#tegs").modal();
		return false;
	});

	$('#tegs').on('shown',function(){

		$("#tegs .tri-checkbox").attr( {state: "none",checktype: "double", def: "uncheck"} );

		var orderIds = getOrderIds();
		if(orderIds.length == 0) return;
		var tegs = [];

		var data = { act: "get_same_tags", order_ids: orderIds }

		$.ajax({
			url: '/admin/orders/batch',
			type: 'put',
			data: data,
		})
		.done(function(res) {
			$.each(res,function(index,val){
				var attr = { state: val };
				if(val=="none") attr["def"] = "uncheck";
				if(val=="part")  attr["def"] = "partcheck"
				if(val=="all") attr["def"] = "checked"

				attr["checktype"] = "double";
			       if(val=="part") attr["checktype"] = "triplet";

				$("#tegs .tri-checkbox[value='"+index+"']").attr(attr);
			});
		});
		// .fail(function() {
		// 	console.log("error");
		// })
		// .always(function() {
		// 	console.log("complete");
		// });
	});

	$("#tegs #tagged").click(function(){
		if($("#batch_inputs input").length==0){
			alert("请选择要操作的数据项！");
			return false;
		}
		if($(this).hasClass('disabled')) return false;
		$(this).addClass("disabled");

		var url = "/admin/orders/batch"
		var orderIds = getOrderIds();
		var  tegs = [];
		var tagId,checktype,state,def;
		
		$("#tegs .tri-checkbox[checktype='triplet']").each (function(){
			tagId = $(this).attr("value");
			def = $(this).attr("def");
			state =$(this).attr("state");
			tegs.push({ tag_id: tagId, def: def, state: state });
		});
		$("#tegs .tri-checkbox[checktype='double'][def='uncheck'][state='all']").each(function(){
			tagId = $(this).attr("value");
			def = $(this).attr("def");
			state =$(this).attr("state");
			tegs.push({ tag_id: tagId, def: def, state: state });
		});

		$("#tegs .tri-checkbox[checktype='double'][def='checked'][state='none']").each(function(){
			tagId = $(this).attr("value");
			def = $(this).attr("def");
			state =$(this).attr("state");
			tegs.push({ tag_id: tagId, def: def, state: state });
		});



		var data = { act: "tag", order_ids: orderIds, tegs: tegs }
		var _btn =  this;
		$.ajax(url,{
			type: "put",
			data: data,
			success: function(res){
				var reqUrl = $("#orders").attr("data-url");
				$.getScript(reqUrl);
				$(_btn).removeClass("disabled");
				$("#batch_inputs").empty();
				$("#tegs .close").trigger("click");
				$("#count").text("0");
				$("#select_page").attr("checked",false);
			}
		});

		return false;
	});
 	
 	$("#batch_actions .batch").click(function(){
 		var orderIds = getOrderIds();
 		if(orderIds.length == 0){
 			$("#batch_actions .btn-group").removeClass("open");
 			alert("请选择要操作的数据项！");
 			return false;
 		}

		if($(this).hasClass('disabled')) return false;
		$(this).addClass('disabled');

		var act = $(this).data("act");

		var url = "/admin/orders/batch"

		var data = { act: act, order_ids: orderIds }
		var _btn =  this;
		$.ajax(url,{
			type: "put",
			data: data,
			success: function(res){
				var reqUrl = $("#order").data("url");
				$.getScript(reqUrl,function(){
					$(_btn).removeClass("disabled");
					if(res.csv) window.location.href =  res.csv;
				});
				$(_btn).removeClass("disabled");
				$("#batch_inputs").empty();
				$("#count").text("0");
				$("#batch_actions .btn-group").removeClass("open");
				$("#select_page").attr("checked",false);
			}
		});

		return false;
 	});
});