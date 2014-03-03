//= require admin/filter
//= require jquery.ui.datepicker
//= require jquery.ui.slider
//= require jquery-ui-timepicker-addon
//= require jquery-ui-sliderAccess
//= require jquery.ui.datepicker-zh-CN
//= require bootstrap-tooltip
//= require bootstrap-popover
//= require bootstrap-modal

$(document).ready(function(){

	$(".datetime").datetimepicker({
		dateFormat: "yy-mm-dd",
		timeFormat: "hh:mm:ss",
		showSecond: true
	});

	$("#goods").on("mouseenter",".hover-thumb",function(){
		$(this).popover({
			html: true,
			trigger: "hover",
			content: function(){
				var img = $(this).data("thumb");
				if(img.length){
					return '<img src="'+$(this).data("thumb")+'" />';
				}else{
					return '无缩略图'
				}
				
			}
		}).popover("show");
	}).on("mouseleave",".hover-thumb",function(){
		$(this).popover("destroy");
	});
	


	$("#goods").on("change","#select_page_all",function(){
		$("#goods .good").attr("checked",$(this).attr("checked")=="checked").trigger("change");
	});

	$("#goods").on("change",".good",function(){
		
		if($(this).attr("checked")=="checked"){
			$(this).closest("tr").addClass("selected");
			if($("#batch_inputs #"+$(this).attr("id")).length==0){
				$("#batch_inputs").append($(this).clone().removeClass("good"));
			}
			
		}else{
			$(this).closest("tr").removeClass("selected");
			$("#batch_inputs" + " #" + $(this).attr("id")).remove();
		}

		$("#count").text($("#batch_inputs :checked").length);
	});

	$("#cancel_all").click(function(){
		$("#batch_inputs").empty();
		$("#goods .good").attr("checked",false).trigger("change");
		$("#select_page_all").attr("checked",false);
        $(".sel_operation").val(0);
		return false;
	});

	$("#select_all").click(function(){
		var ids  = $("#goods").attr("goods_ids").split(",")
		$.each(ids,function(index,val){
			if(val.length>0){
				$("#goods #good_"+val).closest("tr").addClass("selected");
				$("#batch_inputs").append('<input id="good_'+val+'" name="batch[goods_ids][]" checked="checked" type="checkbox" value="'+val+'">');
			}
		});
		$("#count").text($("#goods").attr("count"));
		$("#goods .good").attr("checked",true);
        $(".sel_operation").val(1);
		return false;
	});


	$(".expand").closest("tr").next().hide();
	$(".expand").bind("click",function(){
		$(this).closest("tr").next().toggle();
	});

	var checkSubmit = function(form){
		if(form.find("ul.good-spec-items li").length > 0){
			form.find("input[type='submit']").removeAttr("disabled");
		}else{
			form.find("input[type='submit']").attr("disabled",true);
		}
	};

	$(".add-spec-item").bind("click",function(){
		var url =  $(this).data("url");
		var self = this;
		$.get(url,function(res){
			$(self).closest(".good-spec-header").next("form").find("ul.good-spec-items").append(res);
			checkSubmit($(self).closest(".good-spec-header").next("form"));
		});
		
	});

	$(".remove-spec-item").live("click",function(){
		var url = $(this).data("url"),self = this;
		var form = $(self).closest("form")
		if( url == undefined ){
			$(self).closest("li").remove();
			checkSubmit(form);
		}else{
		   $.post(url,function(res){
		   	    if(res.code == 't') {
		   	    	  $(self).closest("li").remove();
		   	    	  checkSubmit(form);
		   	    }
		   });
		}
	});



	$(".item-selector").live("change",function(){
		var old = $(this).find("option[selected='selected']").val() || '';
		var cur =  $(this).val();
		var _self =  this;
		$(this).closest(".good-spec-items").find("select").not(this).find("option[selected]").each(function(){
			if( cur == $(this).val() ){
				alert("该选项已经选择了!");
				setTimeout(function(){
					$(_self).find("option[selected]").attr("selected",false);
					$(_self).find("option[value='"+old+"']").attr("selected",true);
				},1);
				return true;
			}
		});
		$(_self).find("option[selected]").attr("selected",false);
		$(_self).find("option[value='"+cur+"']").attr("selected",true);
	});

	$(".add-spec-item-field").bind("click",function(){
		var url = $(this).data("url");
		var args = ["dialogHeight=200px","dialogWidth=400px","dialogLeft=50%","center=1"].join(";")
		window.showModalDialog(url,args);
	});


	$("#goods.collocation-goods").on("click",".add-collocation",function(){
		var name = $(this).data("name");
		var goods_id = $(this).data("goods_id");
		var image = $(this).data("image");
		var price  = $(this).data("price");

		var html = '<li data-goods_id="'+goods_id+'"> \
	            <div> \
	              <img src="'+image+'"> \
	            </div> \
	            <div class="name">'+name+'&yen;'+price+'</div> \
	            <input type="hidden" name="collocation[collocations][]" value="'+goods_id+'"> \
	            <a href="#" class="close">×</a> \
          	</li>';

		
		if($("#collocations li[data-goods_id='"+goods_id+"']").length > 0){
			alert("已经添加该商品!");
			return false;
		}
		$("#collocations").append(html);
		return false;
	});

	$("#collocations").on("click",".close",function(){
		$(this).parent("li").remove();
		return false;
	});

	var getGoodIds = function(){
  		var ids = []
  		$("#batch_inputs input").each(function(){
			ids.push($(this).val());
		});

  		return ids;
  	};

	$("#batch_actions .batch").on("click",function(){

		if($("#batch_inputs input").length==0){
			alert("请选择要操作的数据项！");
			$("#batch_actions .btn-group").removeClass("open");
			return false;
		}

		if($(this).hasClass('disabled')) return false;

		$(this).addClass('disabled');
		var act = $(this).data("act");
		var confirmMsg = $(this).data("confirm");
		var result = true;
		if(act=="destroy"){
			var result = confirm(confirmMsg);
		}

		if(!result) return false;

		var url = "/admin/goods/batch"
		var goods_ids = getGoodIds();

		var data = { act: act, goods_ids: goods_ids }
		var _btn =  this;
		$.ajax(url,{
			type: "put",
			data: data,
			success: function(res){
				var search_url = $("#goods").data("url")
				$.getScript(search_url,function(){
					$(_btn).removeClass("disabled");
					if(res.csv){
						window.location.href = res.csv;
					}
				});
				$("#batch_inputs").empty();
				$("#count").text("0");
				$("#batch_actions .btn-group").removeClass("open");

				
			}
		});

		return false;
	});

	$("#pop_tegs").click(function(){
		$("#tegs").modal();
		return false;
	});

	$('#tegs').on('shown',function(){
		$("#tegs .tri-checkbox").attr( {state: "none",checktype: "double", def: "uncheck"} );

		var goodIds = getGoodIds();
		var tegs = [];

		var data = { act: "get_same_tags", goods_ids: goodIds }

		$.ajax({
			url: '/admin/goods/batch',
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
	});

	$("#tegs #tagged").click(function(){
		if($("#batch_inputs input").length==0){
			alert("请选择要操作的数据项！");
			return false;
		}
		if($(this).hasClass('disabled')) return false;
		$(this).addClass("disabled");

		var url = "/admin/goods/batch"
		var goodIds = getGoodIds();
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



		var data = { act: "tag", goods_ids: goodIds, tegs: tegs }
		var _btn =  this;
		$.ajax(url,{
			type: "put",
			data: data,
			success: function(res){
				var reqUrl = $("#goods").data("url");
				$.getScript(reqUrl);
				$(_btn).removeClass("disabled");
				$("#batch_inputs").empty();
				$("#tegs .close").trigger("click");
				$("#count").text("0");
			}
		});

		return false;
	});

	// $('#tegs').on('shown',function(){
	// 	$("#tegs input:checkbox").attr("checked",false);
		
	// 	var goods_ids = [], tegs = [];
	// 	$("#batch_inputs input").each(function(){
	// 		goods_ids.push($(this).val());
	// 	});

	// 	var data = { act: "get_same_tags", goods_ids: goods_ids }

	// 	$.ajax({
	// 		url: '/admin/goods/batch',
	// 		type: 'put',
	// 		data: data,
	// 	})
	// 	.done(function(res) {
	// 		$.each(res,function(index,val){
	// 			$("#tegs input[value='"+val+"']").attr("checked",true);
	// 		});
	// 	})
	// 	.fail(function() {
	// 		console.log("error");
	// 	})
	// 	.always(function() {
	// 		console.log("complete");
	// 	});
	// });


	// $("#tegs #tagged").click(function(){

	// 	if($("#batch_inputs input").length==0){
	// 		alert("请选择要操作的数据项！");
	// 		return false;
	// 	}

	// 	if($(this).hasClass('disabled')) return false;

	// 	$(this).addClass("disabled");

	// 	var url = "/admin/goods/batch"
	// 	var goods_ids = [], tegs = [];
	// 	$("#batch_inputs input").each(function(){
	// 		goods_ids.push($(this).val());
	// 	});

	// 	$("#tegs input[type='checkbox']:checked").each (function(){
	// 		tegs.push($(this).val());
	// 	});

	// 	var data = { act: "tag", goods_ids: goods_ids, tegs: tegs }
	// 	var _btn =  this;
	// 	$.ajax(url,{
	// 		type: "put",
	// 		data: data,
	// 		success: function(res){
	// 			var search_url = $("#goods").data("url")
	// 			$.getScript(search_url);
	// 			$(_btn).removeClass("disabled");
	// 			$("#batch_inputs").empty();
	// 			$("#count").text("0");
				
	// 			$("#tegs .close").trigger("click");

	// 			$("#tegs input:checked").attr("checked",false);
	// 		}
	// 	});

	// 	return false;
	// });
});
