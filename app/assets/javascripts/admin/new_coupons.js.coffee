# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

#= require jquery.ui.datepicker
#= require jquery.ui.slider
#= require jquery-ui-timepicker-addon
#= require jquery-ui-sliderAccess
#= require jquery.ui.datepicker-zh-CN

$ ->
  $(".datetime").datetimepicker({
		dateFormat: "yy-mm-dd",
		timeFormat: "hh:mm:ss",
		showSecond: true
  });

  $("#conditions :radio").bind "change", ->
    $("#input, #select").addClass("hide")
    if $(this).val() == 'order_total_ge_x'
    	$("#condition_val").html('输入 X = <input class="input-mini" name="coupon[condition_val]" type="text">')
    	$("#selected_goods").empty()
    if $(this).val() == 'buy_specify_goods'
       $("#condition_val").html('<a href="#">+选择商品</a>')


   $(".download").click ->
   	count = prompt("请输入下载数量","50")
   	url = $(this).attr("href")
   	$.ajax(url,{
   	  type: "get",
   	  data: { count: count },
   	  success: (res) ->
   	    window.location.replace(res)
   	})
   	false
   $("#toggle_coupon_type :radio").bind "change", ->
      if $(this).attr("checked") == "checked"
         $("#static_coupon_type").text $(this).val()

   false

