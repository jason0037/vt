$ ->
  $(".val").focus ->
    $(this).closest("div").next(".help-tips").empty()

  $(".choice").change ->
    $("#by_text").text($(this).data("text"))
    $("#value_holder").removeClass("hide")
    $("#value_holder .val").val('')
  
  start_countdown = ->
    sec = 60
    $("#sec").text(sec)
    interval_id = setInterval ->
  	   sec = sec - 1
      $("#sec").text(sec)
      if sec == 0
    	  clearInterval(interval_id)
    	  $("#resend").removeClass("disabled")
    	  $("#countdown").hide();
    , 1000
  start_countdown()
  $("#resend").click ->
  	if $(this).hasClass("disabled") 
  	  return false
    $(this).addClass("disabled")
    url = $(this).attr("href")
    params = $(this).data("user")
    $.post url,{ user: params }, ->
      $("#countdown").show()
      start_countdown()
    false
  $("#sms_input_form").submit ->
    token = $(this).find("#token")
    if $.trim(token.val()).length == 0
      $("#help").text("请输入验证码")
      return false
  $("#token").focus ->
    $("#help").empty()




  false