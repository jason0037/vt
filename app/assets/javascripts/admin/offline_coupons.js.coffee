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