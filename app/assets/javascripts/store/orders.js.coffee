#= require jquery
#= require jquery_ujs
#= require area_seletor
#= require jquery.ui.datepicker
#= require jquery.ui.datepicker-zh-CN

window.compute_payment = null

$ ->
  window.compute_payment = ->

    pmt_total = 0.0
    $(".promotions .pmt").each ->
      pmt_total += parseFloat $(this).data("amount") || 0

    coupon_total = 0.0
    coupon_total =  parseFloat($("#matched_coupons").attr("data-amount")) || 0

    pmt_amount = pmt_total + coupon_total
    $("#pmt_amount").text(-pmt_amount).attr("data-amount",pmt_amount)

    order_amount =  parseFloat($("#order_amount").data("amount")) || 0

    coupon_amount =  parseFloat($("#coupon_amount").data("amount")) || 0

    part_amount = 0.0
    part_amount =  parseFloat $("#advance").data("amount") if $("#advance").attr("checked") == "checked"

    pay_amount = order_amount - coupon_amount - pmt_amount
    $("#final_amount").text(pay_amount)

    bcom_discount = 1.0
    if $("#bcom_payment").attr("checked") == "checked"
      bcom_discount = 0.95
      bcom_discount_amount = pay_amount -pay_amount*bcom_discount
      $("#bcom_discount").text(-bcom_discount_amount)

    pay_amount = pay_amount * bcom_discount - part_amount
    $("#pay_amount").text(pay_amount)

  window.compute_payment2 = ->
    products_total = 0.0
    products_total =   parseFloat($("#products_total").data("amount")) || 0

    part_pay = 0.0
    part_pay =  parseFloat($("#advance").data("amount")) || 0  if $("#advance").attr("checked") == "checked"

    pmts_total = 0.0
    pmts_total =  parseFloat($("#pmts_total").data("amount")) || 0

    order_total =  products_total - pmts_total
    bcom_discount = 0.0
    bcom_discount  = order_total - Math.round(order_total*0.95) if $("#bcom_payment").attr("checked") == "checked"

    $("#final_pay").text(order_total - bcom_discount - part_pay)


  compute_payment()

  $("#order_is_tax").bind "change", ->
    if $(this).attr("checked") == "checked"
      $(".tax-input").removeClass "hide"
    else
      $(".tax-input").addClass "hide"

  $("#payments input[type='radio']").bind "change", ->
    if $("#payments input[type='radio']:checked").val() == "bcom"
      $("#installment_on").attr("checked",false).change()
      $("div[for='#order_payment_bcom']").removeClass "hide"
    else
      $("#installment_on").attr("checked",false).change() if $("#payments input[type='radio']:checked").val() != "icbc"
      $("div[for='#order_payment_bcom']").addClass "hide"

    compute_payment()

  $("#payment_choices input[type='radio']").bind 'change', ->
    if $("#payment_choices input[type='radio']:checked").val() == "bcom"
      $("#installment_on").attr("checked",false).change()
      $("div[for='#order_payment_bcom']").removeClass "hide"
    else
      $("#installment_on").attr("checked",false).change() if $("#payments input[type='radio']:checked").val() != "icbc"
      $("div[for='#order_payment_bcom']").addClass "hide"
    window.compute_payment2()

  $("#order_ship_day").bind "change", ->
    if $(this).val() == "special"
      $("#order_ship_special").removeClass("hide")
      $("#order_ship_special").focus()
    else
      $("#order_ship_special").addClass("hide")
      $("#order_ship_special").val('')

  $(".datetime").datepicker({
    dateFormat: "yy-mm-dd",
    minDate: +1
  });

  $(document).on "click", '.update-link', ->
    return false  if $(this).next("form").length>0
    return true


  $(".addr-list").on "change","input[type='radio']", ->
    $(".addr-list .active").removeClass("active").find("form").remove()
    $(this).parent(".radio").addClass("active")


    if $(this).val() == 'new'
      $("#addr_form").removeClass("hide")
      $("#member_addr").val ''
    else
      $("#addr_form").addClass("hide")
      $("#member_addr").val $(this).val()

  $(document).on "focus", ".new-addr input[type='text'], .new-addr select", ->
    $(this).nextAll(".help-inline").empty();


  $("#order_form").submit ->
    if $("#member_addr").val() == ''
      alert "请确认收货地址"
      false

  $(".order-holder").on "click", '#change_payment', ->
    $(".order-holder .payment").remove()
    $(".order-holder #payments").removeClass("hide")
    $(".order-holder #payment_choices").removeClass("hide")
    false

  $("#installment_on").change ->
    if $(this).attr("checked") == 'checked'
      $("#installment_select").removeClass("hide")
    else
      $("#installment_select").addClass("hide")
      $("#installment_select select").val('')

  $("#advance").change ->
    if $(this).attr("checked") == 'checked'
      $("#part_amount").text "-"+$("#advance").data("amount")
    else
      $("#part_amount").text '-0'

    compute_payment()
    compute_payment2()



  $("#coupon_options").change ->
    code = $(this).val()
    $("#coupon_code").val(code)

  $("#coupon_code").keydown (e)->
    if e.keyCode == 13
      e.stopPropagation()
      e.preventDefault()


  $("#check_coupon").click ->
    code = $("#coupon_code").val()
    if code.length == 0
      $("#matched_coupon").empty()
      alert "请输入优惠券"
      $("#coupon_code").focus()
    else
      codes = []
      codes.push(code)
      $("#matched_coupons input:hidden").each ->
        _code  = $(this).val()
        codes.push(_code) if codes.indexOf(_code) < 0

      url = $(this).attr("href")
      $.get( url, { codes: codes }, ->
        window.compute_payment();
      );

    false

  $("#matched_coupons").on "click",".close", ->
    if confirm("确定要删除吗？")
      $(this).closest('tr').remove()
      if $("#matched_coupons tr").length == 1
        $("#matched_coupons").empty().attr("data-amount",0)
        window.compute_payment()

        return false

      codes = []
      $("#matched_coupons input:hidden").each ->
        _code  = $(this).val()
        codes.push(_code) if codes.indexOf(_code) < 0

      url = $(this).attr("href")
      $.get( url, { codes: codes }, ->
        window.compute_payment()
      );

    # $(this).closest('tr').remove()
    # $("#matched_coupons").hide() if $("#matched_coupons tr").length == 1

    false

# $(".addr").on "ajax:complete", "form", (e, res) ->
#   eval(res.responseText)