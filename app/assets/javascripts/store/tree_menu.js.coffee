$ ->
   $(".title-level1").on 'click', ->
   	return false if $(this).next("ul.items-level1:visible").length>0
   	$("ul.items-level1.folded").slideUp("fast");
   	$(this).next("ul.items-level1").slideDown('fast');
   	false