
$(document).ready(function(){
  var pWin = window.parent;
  var pDoc = window.parent.document;
  
  $("#cart .quantity").live("change",function(){
    var quantity = $(this).val();
    if(!/\d+/.test(quantity)) return false;
    var url = $(this).data('url');
    $.ajax(url,{
      type: "PUT",
      data:{ quantity:quantity },
      success:function(res){
      }
    });
  });

  // hide cart
  $("#cart .close,#cart .continue").bind("click",function(){
    $(pDoc).find("#iframe_cart").animate({ marginTop: '-1000px' },'fast',function(){
      $(pDoc).find(".__mask").remove();
    });
    return false;
  });

  // show cart
  $(pDoc).find("body").on("click",".cart-link",function(){
    if($(this).hasClass("login")) return true;
    $(pDoc).find("body").append('<div id="simple_modal_over" class="__mask" style="opacity: 0.3;filter:alpha(opacity=30);position: fixed;display:block;z-index: 99998;top: 0;left: 0;width: 100%;height: 100%;background-color: #000000;background-position: center center;background-repeat: no-repeat;background: -webkit-gradient(radial, center center, 0, center center, 460, from(#ffffff), to(#291a49));background: -webkit-radial-gradient(circle, #ffffff, #291a49);background: -moz-radial-gradient(circle, #ffffff, #291a49);background: -ms-radial-gradient(circle, #ffffff, #291a49);"></div>');
    $(pDoc).find("#iframe_cart").animate({ marginTop: '-260px' },'normal');
    return false;
  });
});