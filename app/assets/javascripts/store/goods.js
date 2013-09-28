//= require jquery.countdown

$(document).ready(function(){

	$("#search_btn").bind("click",function(){
		var key = $.trim($("#search_input").val());
		if(key==''){
			$("#search_input").focus();
		}else{
			window.location.href = "/gallery-index-.html?scontent=n," + key;
		}
	});
	$("#search_input").bind("keydown",function(e){
		if(e.keyCode == 13) $("#search_btn").click();
	});







	$(".custom-save").live("click",function(){
		var data = { custom_values:[] },spec_item_id,value;

		var url = $(this).data("url"),method = $(this).data("method");
		
		$(this).closest("div.popover-content").find("ul.good_spec_items li").each(function(){
			spec_item_id = $(this).find("[name='product[customs][][spec_item_id]']").val();
			value = $(this).find("[name='product[customs][][value]']").val();
			data.custom_values.push({spec_item_id:spec_item_id,value:value});
		});
		var self = this;
		$.ajax(url,{
			type:method,
			data:data,
			success:function(res){
				$(self).closest("td").find(".semi_custom").popover('hide');
			}
		});
	});

	var deadline = parseInt($("#clock").attr("deadline"),10);
	$('div#clock').countdown(deadline, function(event) {
		$this = $(this);
		switch(event.type) {
		      case "seconds":
		      case "minutes":
		      case "hours":
		      case "days":
		        $this.find('span#'+event.type).html(event.value);
		        break;
		      case "finished":
		        $this.fadeTo('slow', .5);
		        break;
		}
  	});

	


	
});
