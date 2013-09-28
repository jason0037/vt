//= require jquery
//= require jquery_ujs
//= require bootstrap
$(document).ready(function(){
  
  $('#topmenu .dropdown').hover(function() {
     $(this).find('.dropdown-menu').stop(true, true).show();
     $(this).addClass('open');
   }, function() {
     $(this).find('.dropdown-menu').stop(true, true).hide();
     $(this).removeClass('open');
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

    var $carousel = $(".carousel");
    var interval = $carousel.data("interval");
    if(interval==undefined) interval = 5000
    $carousel.carousel({
      interval: interval
    });
});