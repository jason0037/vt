
$(function(){

    $('.all-goods .item').hover(function(){
        $(this).addClass('activer').find('s').hide();
        $(this).find('.product-wrap').show();
    },function(){
        $(this).removeClass('activer').find('s').show();
        $(this).find('.product-wrap').hide();
    });
});


function width(){

}
