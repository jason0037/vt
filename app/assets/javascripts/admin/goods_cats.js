$(document).ready(function() {
	$(".folder").click(function(e){
		var cat_path = $(this).attr("cat_path");
		$("td:contains("+cat_path+")").parent().toggle();
	})
});
