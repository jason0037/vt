$ ->
  $("#download").on 'hidden', ->
    $(this).find("#send").removeClass("hide")
    $(this).find("#send #sms_mobile").empty()
    $(this).find("#result").addClass("hide")
    $(this).find("#result #tel").empty()

  $("#send form").submit ->
    if !/^[1-9][0-9]{10}$/.test($("#sms_mobile").val())
      $("#sms_mobile").next(".error").text("电话号码为11位数字")
      return false
    $(this).find(":submit").attr("disabled",true).addClass("disabled")
    $(this).find(".sending").text("正在发送...")
  
  $("#sms_mobile").focus ->
    $(this).next(".error").empty()