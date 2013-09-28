//= require jquery
//= require jquery_ujs
//= require bootstrap
$(document).ready(function(){
	$(document).on("click",".tri-checkbox[checktype='double']",function(){
		var state = $(this).attr("state");
		if(state=="none"){
			$(this).attr("state","all");
		}else{
			$(this).attr("state","none");
		}
	}).on("click",".tri-checkbox[checktype='triplet']",function(){
		var state = $(this).attr("state");
		if(state=="part"){
			$(this).attr("state","all");
		}
		if(state=="all"){
			$(this).attr("state","none");
		}
		if(state=="none"){
			$(this).attr("state","part");
		}
	});
});