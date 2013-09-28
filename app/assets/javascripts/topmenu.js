$(document).ready(function(){
  $('#topmenu .dropdown').hover(function() {
    $(this).find('.dropdown-menu').stop(true, true).show();
    $(this).addClass('open');
  }, function() {
    $(this).find('.dropdown-menu').stop(true, true).hide();
    $(this).removeClass('open');
  });
});