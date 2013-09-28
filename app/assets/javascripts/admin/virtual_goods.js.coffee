$ ->
  $(".close").click ->
    $(this).closest(".alert").remove()
  $("#import").click ->
  	 $("#csvfile").click()
  $("#csvfile").change ->
  	 $(this).closest("form").submit()