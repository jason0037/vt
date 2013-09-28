$ ->
  $("#value_list").on "click", ".delete", ->
    $(this).closest(".actions").find("._destroy").val('true');
    li = $(this).closest("li")
    if li.hasClass("new")
    	li.remove()
    else
      li.hide()
    return false

  $("#add_value").click ->
    len  = $("#value_list li").length - 1
    $("#value_list").append """
    		<li class="new">
                 <span class="name">
                    <input class="span2" name="spec[spec_values_attributes][#{len}][spec_value]" type="text">
                 </span>
                 <span class="alias"><input class="span2" name="spec[spec_values_attributes][#{len}][alias]"  type="text" ></span>
                 <span class="actions">
                    <a href="#" class="delete">×</a>
                 </span>
            </li>
    """
    return false


