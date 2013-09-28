$ ->
  # opener = window.opener.document


  # $("#confirm_select").click ->
  # 	$(opener).find("#specify_goods").empty()
  # 	$("#select_goods input[name='bn']:checked").each ->
  # 	  html_bn = "#{$(this).data('name')} (#{$(this).val()})"
  # 	  hidden_input = "<input name='promotion[goods][]' type='hidden' value='#{$(this).val()}' >"
  # 	  $(opener).find("#specify_goods").append("<li>#{html_bn}#{hidden_input}</li>");
  # 	window.close()
  # 	return false

  # $("#dialog_goods .pagination").on 'click', 'a', ->
  # 	url = $(this).attr("href")
  # 	$.getScript url
  # 	return false