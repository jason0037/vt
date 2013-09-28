//= require jquery
//= require jquery_ujs
//= require supersized_min
//= require jquery_placeholder_min
//= require jquery_jcarousel

jQuery(function($){
  $.supersized({
    // Functionality
    slide_interval    :   12000,
    transition        :   1,
    transition_speed  :   1000,
    performance       :   2,
    // Components     
    slide_links       :   false,
    slides            :    [
                              //{image : 'images/home/episode1/photo1.jpg', title : ''},
                              //{image : 'images/home/episode1/photo2.jpg', title : ''},
                              //{image : 'images/home/episode1/photo3.jpg', title : ''}
                              // {image : 'images/home/episode5/photo2.jpg', title : ''},
                              // {image : 'images/home/episode7/1.jpg', title : ''},
                              // {image : 'images/home/episode7/2.jpg', title : ''},
                              {image : '/assets/3.jpg', title : ''}
                              // {image : 'images/home/episode7/4.jpg', title : ''}
                              
                           ]
  });

  $('.mobile_form form .btn').click(function(){
      var mobile = $.trim($("#survey_mobile").val());
      if(mobile.length==0){
        $(".help-block").show().text("请输入您的手机号码").fadeOut(1500);
        $("#survey_mobile").focus();
        return false;
      }else if(!/^\d{11}$/.test(mobile)){
          $(".help-block").show().text("请输入11位手机号码").fadeOut(1500); 
          $("#survey_mobile").focus();
          return false;
      }else{
        // $(".options,.mobile_form").hide();
        // $(".loading").show();
        $(".mobile_form form").submit();
      }
  });

  



});
