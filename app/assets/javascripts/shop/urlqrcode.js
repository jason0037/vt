/**
 * Created by daizhiyu on 14/12/15.
 */

function image() {
    var drawing = document.getElementById("canvas");


//    var image = document.createElement('img');
    var image = new Image();


    var imgURI = drawing.toDataURL("image/png");

    image.src = imgURI;
    if ($("#qrcodeimg").children("img").length == 0) {
        $("#qrcodeimg").append(image);


    }
}

$=Zepto;
$(".look").bind('click',function(){
    image();
})
$('#qrcodeCanvas').bind('click', function () {
    if ($.AMUI.fullscreen.enabled) {
        $.AMUI.fullscreen.request();
    } else {
        // Ignore or do something else
    }
});