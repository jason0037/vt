# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

#= require jquery.ui.datepicker
#= require jquery.ui.slider
#= require jquery-ui-timepicker-addon
#= require jquery-ui-sliderAccess
#= require jquery.ui.datepicker-zh-CN


$ ->
  $("#promotion_action_type").bind "change", ->
  	action_type = $(this).val();
  	$(".action-content").html $("#pmt_actions .#{action_type}").html()

  $(".datetime").datetimepicker({
		dateFormat: "yy-mm-dd",
		timeFormat: "hh:mm:ss",
		showSecond: true
   });

  $("#conditions input[type='radio']").bind "change", ->
    if  $(this).attr("checked") == 'checked'
      if $(this).val() == 'none'
        $("#condition_input").addClass("hide").find("input").val('')
      else
        $("#condition_input").removeClass("hide").find("input").val('')



  $("#actions :radio").bind "change", (event, edit=true)->
    
    if $(this).attr("checked") == 'checked'
      switch $(this).val()
        when 'coupon'  then $("#solution").html('<a href="#" class="select-coupons">+选择优惠券</a>').nextAll("ul")
        when 'gift' then $("#solution").html('<a href="#" class="select-gifts">+选择赠品</a>')
        when 'good' then $("#solution").html('<a href="#" class="select-goods">+选择商品</a>')
        else  
          y = $("#actions").data("val") 
          $("#solution").html($(this).data("desc") + ', 输入Y = <input class="input-mini" name="promotion[action_val]" type="text" value="'+y+'"/>')
      $("#solution").nextAll("ul").empty() if edit

  $("#actions :radio").trigger('change',[false])


  $("#brands #select_all_brands").bind "change", ->
    $("#brands input[name]").attr("checked",!!$(this).attr("checked"))

  $("#cats #select_all_cats").bind "change", ->
    $("#cats input[name]").attr("checked",!!$(this).attr("checked"))

  $("#cats input:checkbox").bind "change", ->
     cat_id = $(this).val()
     if $(this).attr('checked') == 'checked'
       $("#cats input[data-parent_id='"+cat_id+"']").attr("checked", !!$(this).attr("checked")).change()

  $("#select_field").bind "change", ->
    field = $.trim $(this).val()
    if field.length > 0
      $("#in_or_not").removeClass("hide")
    else
      $("#in_or_not").addClass("hide")

    $("#choices div[for]").addClass("hide")
    $("#choices div[for='"+field+"']").removeClass("hide")