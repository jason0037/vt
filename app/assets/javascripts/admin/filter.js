$(document).ready(function(){

	var checkSelection = function(){
		$("#goods .good:checkbox").attr("checked",function(){
			var result;
			if($("#batch_inputs input[name='batch[select_all]']").length){
				result = true
			}else{
				var id = $(this).attr("id");
				result = !!$("#batch_inputs #"+id).attr("checked");
			}
			if(result){
				$(this).closest("tr").addClass("selected");
			}else{
				$(this).closest("tr").removeClass("selected");
			}
			return result;
		});
	};
	
	$("#toggle_search").click(function(){
		$("#simple_search,#advanced_search").toggle();
		if($("#simple_search").is(":visible")){
			$(this).text("高级搜索>>");
		}
		if($("#advanced_search").is(":visible")){
			$(this).text("简单搜索>>")
		}
	});

	$(".pagination").on("click","a",function(){
		var url = $(this).attr("href");
		$.getScript(url,checkSelection);
		return false;
	});



	$("#reset_form").click(function(){
		$("#advanced_search")[0].reset();
		$("#advanced_search").submit();
		return false;
	});

	$("#goods").on("click",".order",function(){
		var url = $("#goods").attr("data-url");
		var field = $(this).attr("data-field");
		var sorter = $(this).attr('data-sorter');
		var orderBy = field + "-" + sorter;
		$.ajax(url,{
			type: "get",
			data: { order : orderBy },
			dataType: "script",
			success: checkSelection
		});
		return false;
	});
});