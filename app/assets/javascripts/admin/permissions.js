$(document).ready(function(){
	$("input[type='checkbox']").not("input[name^='permission']").bind("change",function(){
		// var parent = $(this).attr("name");
		// var id = "input[id^='permission_"+parent+"']";
		// $(id).attr("checked",$(this).attr("checked")=="checked");
		$(this).closest('.controller').find("ul li :checkbox").attr("checked",$(this).attr("checked")=="checked");

	});
});