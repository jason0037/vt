# //= require area_seletor

# $ ->
#   $("form").on "ajax:success", (e,res) ->
#     window.location.href = '/member_addrs'

#   $("form").on "ajax:error", (e,res) ->
#     eval(res.responseText);

# $(document).on "focus", ".new-addr input[type='text'], .new-addr select", ->
#      $(this).nextAll(".help-inline").empty();