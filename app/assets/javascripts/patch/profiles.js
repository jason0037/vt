//= require jquery
//= require jquery_ujs
//= require area_seletor
//= require bootstrap

$(document).ready(function(){

	var url =  window.location.search;
	if(/modify=email/.test(url)) $("#ecstore_user_email").focus();
	if(/modify=mobile/.test(url)) $("#ecstore_user_mobile").focus();

	$("#basic_form").bind("submit",function(){
		var email = $("#ecstore_user_email").val();
		var regex = /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i;
		if(!regex.test(email)){
		   $("#ecstore_user_email").next(".help-block").remove();
		   $("#ecstore_user_email").after('<span class="help-block">请输入正确的Email地址</span>');
		   return false;
		}
	});

	// $("#password_form").submit(function(){
	//     var $current = $("#account_current_password");
	//     var $new = $("#account_new_password")
	// });

	$(".notice").fadeOut(2000);


	$("#ecstore_user_province").bind("change",function(){
		
		var province = $(this).val();
		$("#ecstore_user_city,#ecstore_user_district").remove();
		makeArea();
		if(province=="") {
			$("#ecstore_user_addr").val("");
			return;
		}

		var city_select = '<select id="ecstore_user_city" name="ecstore_user[city]" onchange="selectDistrict(this);"></select>';
		
		if($("#ecstore_user_city").length==0){
			$(this).after(city_select);
		}
		$("#ecstore_user_city").empty().append('<option value="">请选择</option>');
		for (var e in _cities[province]){
			var city = _cities[province][e];
			$("#ecstore_user_city").append(new Option(city.local_name,city.region_id));
		}

		$("#ecstore_user_area").val("");
		makeAddr();
	});
});

function selectDistrict(selector){
	
	$("#ecstore_user_district").remove();
	// makeArea();
	makeAddr();
	var city = $(selector).val();
	if (_districts[city]==undefined || _districts[city].length == 0) return;
	var district_select = '<select id="ecstore_user_district" name="ecstore_user[district]" onchange="makeAddr(this);"></select>';
	
	if($("#ecstore_user_district").length==0){
		$(selector).after(district_select);
	}
	$("#ecstore_user_district").empty().append('<option value="">请选择</option>');
	
	for (var e in _districts[city]){
		var district = _districts[city][e];
		$("#ecstore_user_district").append(new Option(district.local_name,district.region_id));
	}
}

function makeAddr(selector){
	var objProvince = $("#ecstore_user_province option:selected");
	var objCity = $("#ecstore_user_city option:selected");
	var objDistrict = $("#ecstore_user_district option:selected");
	var province = "", city="",district = "", addr="";

	if(objProvince.val()!=""){
		province = objProvince.text();
	}
	if(objCity.val()!=""){
		city = objCity.text();
	}
	if(objDistrict.val()!=""){
		district = objDistrict.text();
	}

	if(province==city.substr(0,2)){
		addr =  city+district;
	}else{
		addr = province + city + district;
	}
	$("#ecstore_user_addr").val(addr);

	makeArea();
}

function  makeArea(){

	var area = '';

	var p = $("#ecstore_user_province option:selected");

	if(p.val()!=""){
		area+=p.text()+":"+p.val();
	}

	var c = $("#ecstore_user_city option:selected");

	if(c.length>0&&c.val()!=""){
		area = area.split(":")[0];
		area+="/"+c.text()+":"+c.val();
	}
	var d = $("#ecstore_user_district option:selected");
	if(d.length>0&&d.val()!=""){
		area = area.split(":")[0];
		area+="/"+d.text()+":"+d.val();
	}
	if(area!=""){
		area ="mainland:" + area;
	}
	
	$("#ecstore_user_area").val(area);
	
}