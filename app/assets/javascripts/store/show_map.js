var myMap =  null;
$(document).ready(function(){


	$(".show-map").click(function() {
	      var data, lat, lng;
	      data = $(this).data();
	      lat = data.latitude;
	      lng = data.longitude;
	      if (myMap !== null) {
	        myMap.removeMarkers();
	        myMap.setCenter(lat, lng);
	        myMap.addMarker({ lat: lat, lng: lng});
	        return;
	      }
	      myMap = new GMaps({
	        div: '#locate',
	        lat: lat,
	        lng: lng,
	        height: '400px',
	        width: '100%',
	        zoomControl: true,
	        zoomControlOpt: {
	          style: 'SMALL',
	          position: 'TOP_LEFT'
	        },
	        panControl: false,
	        streetViewControl: false,
	        mapTypeControl: false,
	        overviewMapControl: false
	      });
	      myMap.setCenter(lat, lng);
	      myMap.addMarker({lat: lat,lng: lng});
   });


});