


$(document).ready(function(){
	var orderId = window.location.hash.substr(1);
	if(!/^\d{14}$/.test(orderId)) return;
	$("#order_"+ orderId).addClass("success");
});