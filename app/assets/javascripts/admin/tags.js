//= require farbtastic
$(document).ready(function() {
	$('#colorpicker').farbtastic(function(color){
		$("#color").css({ 
			backgroundColor: color,
			color: this.hsl[2] > 0.5 ? '#000' : '#fff'
		});

		$("#bgcolor").val(color);
		$("#fgcolor").val(this.hsl[2] > 0.5 ? '#000000' : '#ffffff');
	});
});
