//= require jquery
//= require jquery_ujs
//= require jquery_jcarousel

$(document).ready(function() {
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
  
  $('#blog_items').jcarousel({
    wrap: 'circular',
    scroll: 4
  });
})