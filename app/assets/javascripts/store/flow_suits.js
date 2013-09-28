//= require jquery
//= require jquery_ujs
//= require jquery_hoverdelay
//= require jquery_isotope
//= require jquery_infinitescroll
//= require jquery_imagesloaded
//= require bootstrap-dropdown
//= require topmenu

$(document).ready(function(){
    $container = $("#container");
    $container.imagesLoaded(function(){
	$container.isotope({
		itemSelector : '.item',
		layoutMode : 'masonry'
	});
     });
    
    $container.imagesLoaded(function(){
	    $container.infinitescroll({
	      navSelector  : '#page_nav',    // selector for the paged navigation 
	      nextSelector : '#page_nav a',  // selector for the NEXT link (to page 2)
	      itemSelector : '.item',     // selector for all items you'll retrieve
	      loading: {
	          finishedMsg: '无更多套装',
	          msgText: "正在加载更多套装...",
	          img: '/assets/progress.gif'
	        }
	      },
	      // call Isotope as a callback
	      function( newElements ) {
	        $container.imagesLoaded(function(){
	            $container.isotope( 'appended', $( newElements ) ); 
	        });
	      }
	    );
    });

    $("#backToTop").click(function() {
      $("html, body").animate({ scrollTop: 0 }, 100);
    });
    $(window).bind("scroll", function() {
      var st = $(document).scrollTop(), winh = $(window).height();
      (st > 0)? $("#backToTop").show(): $("#backToTop").hide();
      if (!window.XMLHttpRequest) { //IE6
        $("#backToTop").css("top", st + winh - 166);
      }
    });

    $("#search_bar form").submit(function(){
      if($.trim($("#search_input").val()).length == 0){
         $("#search_input").focus();
         return false;
      }
    });

});