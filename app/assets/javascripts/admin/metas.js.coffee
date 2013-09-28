# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$ ->
  $("#add_params").click ->
  	$(this).before """
	   <div class="sub">
              <input class="input-small"  name="meta[params][][k]" placeholder="参数名" type="text">
              <input class="input-small"  name="meta[params][][v]" placeholder="参数值" type="text">
              <a href="#" class="delete">&times;</a>
          </div>
  	"""
  	false

  $("#params").on "click", "a.delete", ->
  	$(this).parent(".sub").remove()
  	false
