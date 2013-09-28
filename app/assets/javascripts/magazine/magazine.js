//= require magazine/jCarousel

// 获取目录
function getTopicList(callBack) {
    $.ajax({
        url: "/list_topics.xml?page=1",
        dataType: 'xml',
        type: 'GET',
        timeout: 2000,
        success: function(xml) {
            if(callBack){
                callBack(xml);
            }
        }
    });
}


// 获取杂志内容
function getMagezineContent(name, callBack){
    $.ajax({
        url: "/topics/"+name+"/pages",
        dataType: 'html',
        type: 'GET',
        timeout: 2000,
        async : false,
        success: function(data) {
            if(callBack){
                callBack(data);
            }
        }
    });
}

function pageJump(page) {
    var carousel = $('.iModecMagazine-container');
    carousel.jcarousel('reload', {
        'animation': false
    });
    carousel.jcarousel('scroll', (page - 1));
    carousel.jcarousel('reload', {
        'animation': true
    });
}


function magazineInit(magazineName) {

    var iModecMagazine = $("#iModecMagazine"),
        carousel = $('.iModecMagazine-container'),
        num = 0,
        hasTpoic = false,
        currentPage;



    //加载杂志内容
    getMagezineContent(magazineName, function(data){
        if(data){
            carousel.append(data);
            num = carousel.find("li").length;

            carousel.find("li").each(function(i){
                $(this).addClass("page" + (i+1));
            })
            carousel.find("ul").append("<li class='tipicsCon'></li>");
        }else{
            alert("请稍后再试");
        }
    });

    getTopicList(function(xml){
        var str = '<dl class="magazineList clearfix"><dt><h3>目录 TOPIC DIRECTORY</h3><a class="back_to_topics" href="/topics">返回资讯首页</a></dt>';
        $(xml).find("imodec-topic").each(function(i){
            var img = "http://blog.i-modec.com" + $(this).children("body").text();
            var title = $(this).children("slug").text();
            var createdTime = $(this).children("created-at").text();
            var atTime = createdTime.split(/[T\+]/);
            // atTime.pop();
            createdTime = atTime[0];
            var url = "http://blog.i-modec.com/topics/" + $(this).children("slug").text();
            str += '<dd><div class="img"><a href="'+url+'" target="_blank"><img onload="imgResize(this, 232, 115, \'middle\')" src="'+img+'" alt="'+title+'" /></a></div>'; 
            str += '<div class="txt"><p><a href="'+url+'" target="_blank">'+title+'</a></p><p>'+createdTime+'</p></div></dd>';       
        });
        str += "</dl>";
        iModecMagazine.find(".tipicsCon").append(str);
        hasTpoic = true;
    });


    // 滚动效果绑定
    carousel.on('create.jcarousel', function(event, carousel) {
        if (num <= 1) {
            $(".jcarousel-next").addClass("jcarousel-next-dis");
        }
    }).on('scroll.jcarousel', function(event, carousel, target) {
        var bottomPageNum = $(".bottomPageNum");
        currentPage = parseInt(bottomPageNum.html());
        if (target == "+=1") {
            currentPage++;
        } else if (target == "-=1") {
            currentPage--;
        } else {
            currentPage = ++target;
        }
        bottomPageNum.html(currentPage);
    }).jcarousel();
    $('.jcarousel-prev').jcarouselControl({
        target: '-=1'
    });
    $('.jcarousel-next').jcarouselControl({
        target: '+=1'
    });
    $('.jcarousel-prev').on('inactive.jcarouselcontrol', function() {
        $(this).addClass("jcarousel-prev-dis");
    });
    $('.jcarousel-next').on('inactive.jcarouselcontrol', function() {
        $(this).addClass("jcarousel-next-dis");
    });
    $('.jcarousel-prev').on('active.jcarouselcontrol', function() {
        $(this).removeClass("jcarousel-prev-dis");
    });
    $('.jcarousel-next').on('active.jcarouselcontrol', function() {
        $(this).removeClass("jcarousel-next-dis");
    });

    $('.jcarousel-next, .jcarousel-prev').click(function(){
        // setHistoryState(currentPage);
    })


    // 生成底部导航
    // var bottomStr = ""
    // for(var i = 0; i <= num; i++){
    //    bottomStr += '<li><a href="javascript:void(0);">'+ (i+1) +'</a></li>';
    // }
    // iModecMagazine.find(".bottomNavItem ul").append(bottomStr);
    // iModecMagazine.find(".bottomNavItem p").html(magazineName);

    // // 更多
    // iModecMagazine.find(".bottomNav .more").click(function(){
    //     carousel.jcarousel('scroll', num);
    //     setHistoryState(num + 1);
    // })


    // // 底部目录
    // iModecMagazine.find(".bottomNavItem a").click(function() {
    //     var num = parseInt($(this).html());
    //     carousel.jcarousel('scroll', (num - 1));
    //     setHistoryState(num);
    // });

    // var timer;

    // iModecMagazine.find(".bottomNav").hover(
    //     function() {
    //         var that = $(this);
    //         if (timer) {
    //             clearTimeout(timer);
    //         }
    //         that.animate({
    //             height: "130px"
    //         }, 300, function() {
    //             that.removeClass("bottomNavHide");
    //         }).removeClass("bottomNavHide");
    //     },
    //     function() {
    //         var that = $(this);
    //         if (timer) {
    //             clearTimeout(timer);
    //         }
    //         timer = setTimeout(function() {
    //             that.animate({
    //                 height: "2px"
    //             }, 300, function() {
    //                 that.addClass("bottomNavHide");
    //             });
    //         }, 500);
    //     }
    // );

    // 点击购买闪烁
    iModecMagazine.find(".style1 a span, a.goods span").queue(function(next) {
        $(this).fadeIn(600).delay(600).fadeOut(600);
        $(this).queue(arguments.callee);
        next();
    });

    iModecMagazine.find(".style1 a, a.goods").hover(
        function() {
            $(this).addClass("hover");
        },

        function() {
            $(this).removeClass("hover");
        }
    );

    iModecMagazine.find("area").hover(
        function() {
            var offsetX = $(this).parents("li").offset().left;
            var offsetY = $(this).parents("li").offset().top;
            var index = $(this).index();
            $(this).mousemove(function(event) {
                var x = event.clientX - offsetX + 10 + "px";
                var y = event.clientY - offsetY + 10 + "px";
                $(this).parents("li").find(".goodsBox").eq(index).css({
                    "left": x,
                    "top": y
                }).show();
            })
        },
        function() {
            $(this).parents("li").find(".goodsBox").hide();
        }
    );

    // historyInit();

}

function historyInit(){
    var History = window.History; // Note: We are using a capital H instead of a lower h
    if ( !History.enabled ) {
         // History.js is disabled for this browser.
         // This is because we can optionally choose to support HTML4 browsers or not.
        return false;
    }

    var State = History.getState(); // Note: We are using History.getState() instead of event.state
    if(State.data.state){
        pageJump(State.data.state);
    }

    // Bind to StateChange Event
    History.Adapter.bind(window,'statechange',function(){ // Note: We are using statechange instead of popstate
        var State = History.getState(); // Note: We are using History.getState() instead of event.state
        var carousel = $('.iModecMagazine-container');
        carousel.jcarousel('scroll', (State.data.state - 1));
    });
}


//设置hash
function setHistoryState(page){
    History.pushState({state:page,rand:Math.random()}, "", "?page=" + page);
}


/* 图片等比压缩 */
function imgResize(oThis, resizeWidth, resizeHeight, position){
    var curImg = $(oThis);
    curImg.css("height", "");
    curImg.css("width", "");
    curImg.css("margin-left", "");
    curImg.css("margin-top", "");
    var picHeight = curImg.height();
    var picWidth = curImg.width();
    var heightPercent = picHeight/resizeHeight;
    var widthPercent = picWidth/resizeWidth;
    if(heightPercent >= widthPercent && heightPercent > 1 && resizeHeight){
        var changeWidth = parseInt((resizeHeight/picHeight)*picWidth);
        curImg.css("height", resizeHeight+"px");
        var marginNum = Math.abs(resizeWidth - changeWidth);
    }else if(widthPercent > 1 && resizeWidth){
        var changeHeight = parseInt((resizeWidth/picWidth)*picHeight);
        curImg.css("width", resizeWidth+"px");
        var marginNum = Math.abs(resizeHeight - changeHeight);
        if(position == "middle"){
            curImg.css("margin-top", parseInt(marginNum/2)+"px");
        }else if(position != "top"){
            curImg.css("margin-top", marginNum+"px");
        }
    }else{
        if(position == "middle"){
            curImg.css("margin-top", parseInt((resizeHeight - picHeight)/2)+"px");
        }
    }
    $(oThis).parents(".jImgLoading").removeClass("jImgLoading");
}