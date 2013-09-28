$ ->
  $("form").on 'click', '.delete', ->
  	$(this).closest("div.item").remove()

  $("#sliders .add").on 'click',->
  	item_count = $("#sliders div.item").length
  	$(this).closest('div').before """
  		<div class="item">
			<span>#{item_count + 1}.</span>
			<input  name="home[sliders][][pic_url]" placeholder="图片地址" type="text" class="span4">
			<input  name="home[sliders][][link_url]" placeholder="图片链接" type="text" class="span4">
			<a href="javascript:void(0);" class="delete">×</a>
		</div> """
  
  $("#keywords .add").on 'click',->
  	item_count = $("#keywords div.item").length
  	$(this).closest('div').before """
  		<div class="item">
			<span>#{item_count + 1}.</span>
			<input  name="home[keywords][][word]" placeholder="关键字" type="text">
			<input  name="home[keywords][][link_url]" placeholder="关键字链接" type="text" class="span4">
			<a href="javascript:void(0);" class="delete">×</a>
                   <span class="pos-control">
                      <i class=" icon-arrow-up"></i>
                      <i class=" icon-arrow-down"></i>
                   </span>
		</div> """
  
  $("#keywords").on 'click','i.icon-arrow-up',->
  	$("#keywords .item").removeClass 'cur'
  	prevItem = $(this).closest(".item").prev(".item");
  	return unless prevItem.is 'div.item'
  	curItem = $(this).closest(".item").detach();
  	prevItem.before(curItem.addClass('cur'));
  	$("#keywords .item").each (idx) ->
  		$(this).find(".no").text("#{idx+1}.");

  $("#keywords").on 'click','i.icon-arrow-down',->
  	$("#keywords .item").removeClass 'cur'
  	nextItem = $(this).closest(".item").next(".item");
  	return unless nextItem.is 'div.item'
  	curItem = $(this).closest(".item").detach();
  	nextItem.after(curItem.addClass('cur'));
  	$("#keywords .item").each (idx) ->
  		$(this).find(".no").text("#{idx+1}.");
