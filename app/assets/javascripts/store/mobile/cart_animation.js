function addProduct(event) {
    var  thisbutton= $(this);
    if(!thisbutton.hasClass("dis-click")){
        var scrollTop = $(window).scrollTop();
        var offset = $('#cart').offset();
        var img= thisbutton.parents().children().children(".beisaier");

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
                thisbutton.addClass("dis-click");
                var url="/cart/add" ;
                var goods_id= thisbutton.prev().val();

                $.ajax(url,{
                    type: "post",
                    data:{"goods_id":goods_id,"spec": "","attr":"mall"  },

                    success:function(res){

                    }
                })

            } //结束回调


        });
    }       }







