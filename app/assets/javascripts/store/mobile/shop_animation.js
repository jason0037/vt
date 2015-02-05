function addProduct(event) {
     var shop_id=$("#shop_id").val();
    var  thisbutton= $(this);

  var cart_num=  $("#cart_num").text();

    if(!thisbutton.hasClass("am-btn-default")){
        var scrollTop = $(window).scrollTop();
        var offset = $('#cart').offset();
        var img= thisbutton.parents().prev("li").children(".beisaier");


        img.removeClass("hide");

        img.fly({
            start: {
                left: event.clientX,
                top: event.clientY
            },
            end: {
                left: offset.left,
                top: offset.top-scrollTop,
                width: 0,
                height: 0
            },
            autoPlay: true, //是否直接运动,默认true
            speed: 1.1, //越大越快，默认1.2

            onEnd: function(){
                img.remove();

                thisbutton.removeClass("am-btn-danger").addClass("am-btn-default");
                var url="/shop/visitors/my_add_shopping"
                var goods_id= thisbutton.parent().children(".goods_id").val();

                $.ajax(url,{
                    type: "post",
                    data:{"goods_id":goods_id,"spec": "","attr":"mall","platform":"shop","shop_id": shop_id },
           success:function(res){
                      $("#cart_num").text(cart_num*1+1);
                    }
                })

            } //结束回调


        });
    }       }







