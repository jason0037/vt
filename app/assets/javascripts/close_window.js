window.hackClose = function(){
	window.opener = null; //for Ie6
	window.open("","_self");  //for ie7-8 
	window.close();
}
