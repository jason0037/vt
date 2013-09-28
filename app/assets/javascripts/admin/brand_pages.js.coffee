$ ->
  $("form").on 'click', '.delete', ->
  	$(this).closest("div.item").remove()

  $("#menus .add").on 'click',->
  	item_count = $("#menus div.item").length
  	$(this).closest('div').before """
  		<div class="item">
			<span class="no">#{item_count + 1}.</span>
			<input class="input_small" name="brand_page[context][][menu_name]" placeholder="菜单名" type="text" >
			<input class="span4" name="brand_page[context][][image_url]" placeholder="图片地址" type="text" >
			<input class="span4" name="brand_page[context][][image_alt]" placeholder="图片描述信息(alt)" type="text" >
			<a href="javascript:void(0);" class="delete">×</a>
			<span class="pos-control">
              		<i class=" icon-arrow-up"></i>
              		<i class=" icon-arrow-down"></i>
        		</span>
		</div> """
  
  
  $("#menus").on 'click','i.icon-arrow-up',->
  	$("#menus .item").removeClass 'cur'
  	prevItem = $(this).closest(".item").prev(".item");
  	return unless prevItem.is 'div.item'
  	curItem = $(this).closest(".item").detach();
  	prevItem.before(curItem.addClass('cur'));
  	$("#menus .item").each (idx) ->
  		$(this).find(".no").text("#{idx+1}.");

  $("#menus").on 'click','i.icon-arrow-down',->
  	$("#menus .item").removeClass 'cur'
  	nextItem = $(this).closest(".item").next(".item");
  	return unless nextItem.is 'div.item'
  	curItem = $(this).closest(".item").detach();
  	nextItem.after(curItem.addClass('cur'));
  	$("#menus .item").each (idx) ->
  		$(this).find(".no").text("#{idx+1}.");

  $("td.ordernum").on 'dblclick', ->
      return if $(this).parent("tr").hasClass 'error'
      return  if $(this).find("input").length > 0
      ordernum =  $.trim $(this).text()
      $(this).html """
        <input class="input-mini ordernum" id="ordernum" name="ordernum" type="number" value="#{ordernum}">
      """
      $(this).find("input").focus();
      
  $("td.ordernum").on 'blur', 'input', ->
      ordernum = $(this).val()
      url =  $(this).parent("td.ordernum").data "url"
      $(this).parent("td.ordernum").text(ordernum);

      $.ajax(url,{
         type: "put",
         data: { ordernum: ordernum },
         success: ->
            window.location.reload();
      });

  return

