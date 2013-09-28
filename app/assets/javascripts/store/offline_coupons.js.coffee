# = require store/show_map
# = require store/download_coupon
$ ->
  $(".show-all").click ->
    $("#addrs .address").removeClass("hide")
    $(this).hide()
    return false
  
  false