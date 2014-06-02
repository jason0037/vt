//=require jquery
//=require jquery_ujs
//=require bootstrap-transition
//=require bootstrap-carousel
//=require jquery_placeholder_min

$(document).ready(function(){

   /* LOGIN ELEMENT */
  $('input[placeholder]').placeholder();


  $('#modal_login .modal_login_nav li').bind('click', function() {
    lc.data('jcarousel').scroll(jQuery.jcarousel.intval($(this).text()), false);
    $('#modal_login .modal_login_nav li').removeClass('selected');
    $(this).addClass('selected');
  });

  $('#modal_login .register_link').click(function(){
    $('#modal_login .login_box').animate({ left: '-600px'}, 400, function() { });
    $('#modal_login .register_box').animate({ left: '40px'}, 400, function() { });
  });

  $('#modal_login .login_link, #modal_login .back_btn').click(function(){
    $('#modal_login .register_box').animate({ left: '640px'}, 400, function() { });
    $('#modal_login .login_box').animate({ left: '40px'}, 400, function() { });
  });

  $("#register_form").submit(function(){
      // var ret = true;
      // if(!$("#license").attr("checked")=="checked"){
      //     $(".help-block[rel='license']").text("您还没有阅读注册协议");
      // }else{
      //     $(".help-block[rel='license']").empty();
      // }
      // return ret;

      // $(this).find(".required").each(function(){
      //     var inputVal = $.trim($(this).val());
      //     var inputId = $(this).attr("id");
      //     var placeholder = $(this).attr("placeholder");
      //     var _type = $(this).attr("type");

      //     if(_type!="checkbox"&&inputVal==""){
      //           $(".help-block[rel='"+inputId+"']").text("请填写" + placeholder);
      //            ret = false;
      //     }else if(_type=="checkbox"){
      //        if($(this).attr("checked")==undefined){
      //           $(".help-block[rel='"+inputId+"']").text("您还没有阅读注册协议");
      //           ret = false;
      //        }
      //     }else{
      //       $(".help-block[rel='"+inputId+"']").empty();
      //     }
      // });

      // $(this).find(".email").each(function(){
      //     var inputVal = $.trim($(this).val());
      //     var inputId = $(this).attr("id");
      //     var placeholder = $(this).attr("placeholder");
      //     if(inputVal.length==0) {
      //         return;
      //     }

      //     if(/^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i.test(inputVal)){
      //         $(".help-block[rel='"+inputId+"']").empty();
      //     }else{
      //         $(".help-block[rel='"+inputId+"']").text("邮箱格式不正确");
      //         ret = false;
      //     }
      // });

      // $(this).find(".mobile").each(function(){
      //     var inputVal = $.trim($(this).val());
      //     var inputId = $(this).attr("id");
      //     var placeholder = $(this).attr("placeholder");
      //     if(inputVal.length==0) {
      //         return;
      //     }
      //     if(/^[1-9][0-9]{10}$/i.test(inputVal)){
      //         $(".help-block[rel='"+inputId+"']").empty();
      //     }else{
      //       $(".help-block[rel='"+inputId+"']").text("手机号码必须是11位数字");
      //       ret = false;
      //     }
      // });

      // if($("#user_login_password_confirmation").val()!=$("#user_login_password").val()){
      //     $(".help-block[rel='user_login_password_confirmation']").text("两次输入密码不一致");
      // }
      // return ret;
  });

});