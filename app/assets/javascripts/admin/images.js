//= require jquery.ui.datepicker
//= require jquery.ui.slider
//= require jquery-ui-timepicker-addon
//= require jquery-ui-sliderAccess

$(document).ready(function(){
	$(".datetime").datetimepicker({
		dateFormat: "yy-mm-dd",
		timeFormat: "hh:mm:ss",
		showSecond: true
	});
});