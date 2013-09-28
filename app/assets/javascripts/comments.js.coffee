# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
  $("#comment_form form").submit ->
  	if $.trim($(this).find("#comment_content").val()).length == 0
  	  alert "请输入评论内容"
  	  return false