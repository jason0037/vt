$ ->
  check_mobile = (tel) ->
  	if !/^[1-9][0-9]{10}$/.test(tel)
  	  $("#mobile").next(".help-inline").text("请输入正确的手机号码")
  	  return false
  	return true

  check_email = (email) ->
  	if !/^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i.test(email)
  	  $("#email").next(".help-inline").text("请输入正确的邮箱地址")
  	  return false
  	return true

  check_code = (code) ->
  	if code.length < 6
  	   $("#sms_code").next(".help-inline").text("请输入6位验证码")
  	   return false
  	else
  	  return true

  $("#mobile").blur ->
  	tel = $(this).val()
  	check_mobile(tel)

  $("#send_form").submit ->
    if check_mobile($("#mobile").val())
    	$(this).find(":submit").attr("disabled",true)
    	return true
    else
      return false

   $("#email_form").submit ->
      if check_email($("#email").val())
    	  $(this).find(":submit").attr("disabled",true)
    	  return true
      else
        return false

  $("#verify_form").submit ->
  	code = $(this).find("#sms_code").val()

  	if check_code(code)
  	  $(this).find(":submit").attr("disabled",true)
  	else
  	  return false

  $("#mobile,#sms_code,#email").focus ->
  	$(this).next(".help-inline").empty()

  