//= require jquery
//= require jquery_ujs
//= require bootstrap-modal
//= require jquery_hoverdelay
//= require jquery_isotope
//= require jquery_infinitescroll
//= require jquery_imagesloaded
//= require bootstrap-dropdown
//= require comments


$(function(){

  // $("#search_input").keydown(function(e){
  //     if(e.keyCode == 13){
  //       $("#search_btn").click();
  //     }
  // });

  // $("#search_btn").click(function(){
  //   var key = $.trim($("#search_input").val());
  //   if(key==""){
  //     $("#search_input").focus();
  //     return;
  //   }
  //   window.location.href = "http://www.i-modec.com/gallery-index-.html?scontent=n," + key;
  // });

  var $container = $('#container');
  $container.imagesLoaded(function(){
        $container.isotope({
            itemSelector: '.element',
            masonry : {
                columnWidth : 235
            },
            onLayout: function( $elems, instance ) {
                // $("#topmenu .container, .categories").css("width", this.width() + 'px');
            }
        });
  });
  

  $('#toggle-sizes').click(function(){
    $container
    .isotope('reLayout');
    return false;
  });

  // Hover Timeout
  var timeout;
  $('.element').live('mouseenter', function(){
    var $element = $(this);
    if (timeout) {
      timeout = clearTimeout(timeout);
    } else {
      timeout = setTimeout(function(){
        timeout = undefined;
        $element.css("z-index", "30");
        $("#shadow").css("z-index", "20").fadeTo(400, 0.6);
      }, 300);
    }
  }).live('mouseleave', function(){
    var $element = $(this);
    if (timeout) {
      timeout = clearTimeout(timeout);
    } else  {
      timeout = setTimeout(function(){
        timeout = undefined;
        $("#shadow").fadeTo(100, 0, function(){
          $("#shadow").css("z-index", "0");
          $element.css("z-index", "10");
        });
      }, 300);
    }
  });

  $container.imagesLoaded(function(){
    $container.infinitescroll({
      navSelector  : '#page_nav',    // selector for the paged navigation 
      nextSelector : '#page_nav a',  // selector for the NEXT link (to page 2)
      itemSelector : '.element',     // selector for all items you'll retrieve
      loading: {
          finishedMsg: '无更多专题',
          msgText: "正在加载更多专题...",
          img: '/assets/progress.gif'
        }
      },
      // call Isotope as a callback
      function( newElements ) {
        $container.imagesLoaded(function(){
            $container.isotope( 'appended', $( newElements ) ); 
        });
      }
    )
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

});


$(document).ready(function(){
  // $(".cart-link").bind("click",function(){
  //      if($(this).hasClass("login")) return;
  //     $("#cart").modal();
  //     $("body").css({'overflow':"hidden"});
  //     return false;
  // });
  // $("#cart").on("hidden",function(){
  //     $("body").css({'overflow':"auto"});
  // });
  // $('.dropdown-toggle').dropdown();

  $('#topmenu .dropdown').hover(function() {
    $(this).find('.dropdown-menu').stop(true, true).show();
    $(this).addClass('open');
  }, function() {
    $(this).find('.dropdown-menu').stop(true, true).hide();
    $(this).removeClass('open');
  });
  
});