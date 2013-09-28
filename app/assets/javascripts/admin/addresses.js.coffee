$ ->
  $("#append_addr").click ->
    vindex  = $("#addresses .control-group:visible").length || 0
    hindex = $("#addresses .control-group").length || 0
    $("#addresses").append """
    	<div class="control-group new">
	      <label class="control-label">地址#{vindex+1}</label>
	      <div class="controls">
	        <input  name="brand[addresses_attributes][#{hindex}][name]" type="text" class="span5">
		 <a href="#" class="delete">&times;</a>
	        <span class="help-block error"></span>
	      </div>
    	</div>
    """
    false
  $("#addresses").on "click",".delete", ->
    holder  = $(this).closest(".control-group")
    if holder.hasClass("old")
      holder.find(".destroy").val(1)
      holder.addClass("hide")
    else
      holder.remove()

    $("#addresses .control-group:visible").each (index) ->
    	$(this).find(".control-label").text("地址#{index+1}")
    false
