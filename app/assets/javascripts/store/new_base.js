//= require jquery
//= require jquery_ujs
//= require jquery-ui-1.9.2.custom
//= require jquery_jcarousel
//= require bootstrap-modal
//= require bootstrap-tooltip
//= require bootstrap-popover
//= require bootstrap-dropdown

var cartScrollTop = null; // scrollTop when cart is shown

$(document).ready(function(){

  $("#search_bar form").submit(function(){
      if($.trim($("#search_input").val()).length == 0){
         $("#search_input").focus();
         return false;
      }
  });


  var cScrolltop;                           // Scroll Position for Drawer
  var cSubpage;                             // Drawer

  $('#topmenu .dropdown').hover(function() {
    $(this).find('.dropdown-menu').stop(true, true).show();
    $(this).addClass('open');
  }, function() {
    $(this).find('.dropdown-menu').stop(true, true).hide();
    $(this).removeClass('open');
  });
  
  $(".scrolling").queue(function(next) {
    $(this).fadeIn(600).delay(600).fadeOut(600);
    $(this).queue(arguments.callee);
    next();
  }); 

  if($('#nav_menu')[0]){
        $('#nav_ul>li').hover(function(){
            $(this).addClass('hover');
            $(this).find('.sub_menu') && $(this).find('.sub_menu').show();
        },function(){
            $(this).removeClass('hover');
            $(this).find('.sub_menu') && $(this).find('.sub_menu').hide();
        });
    }
    $('.sub_menu ul li a').hover(function(){
        $(this).attr('style','background:#000; color:#fff; text-decoration:none;');
    },function(){
        $(this).attr('style','text-decoration:none;')
  });

  // Init BTM Position
  if($(window).height() <= 750) {
    $("#btm_items").attr("style", "top: 2000px;");
  }
  $(window).resize(function(){
    if($(window).width() <= 1200) {
      // $("#menu_cart").hide();
      $("#menu_cart").attr("style", "top: -100px");
    } else {
      $("#menu_cart").attr("style", "top: 0px");
    }
    if($(window).height() <= 750) {
      $("#btm_items").attr("style", "top: 2000px;");
      // console.log("hide");
    } else {
      $("#btm_items").attr("style", "bottom: 0;");
    }
  });

  $(".see_now, .right_arrow").click(function(){
    // $(".drawer").animate()
    cSubpage = $('.drawer');
    cSubpage.animate({ left: '0%'}, 400, function() { });
    $(".left_arrow").show();
    cScrolltop = $(window).scrollTop();
    return false;
  });

  $(".close_drawer, .left_arrow").click(function(){
    // $(".drawer").animate()
    $(".left_arrow").hide();
    cSubpage.animate({ left: '100%'}, 400, function() { });
    cSubpage = null;
    cScrolltop = null;
    return false;
  });
  
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

  $(".spec_bar a.color").live("click",function(){

    $(this).parent().find("a.color").removeClass("selected");
    $(this).addClass("selected");
    $(this).closest("td").find(":hidden").val($(this).data("value"));
    var images = $(this).data("images").split(/\s+/);

    var jcarouselList = $(this).closest(".product_container").find("ul.jcarousel-list li.jcarousel-item");
    if(jcarouselList.length>0){
        for(var i = 0; i < images.length; i++){
            $(jcarouselList[i]).find("img").attr("src",images[i]+"?t="+(new Date).getTime());
            $(jcarouselList[i]).find("a").attr("href",images[i]);
        }
    }

    // $(".zoomWindow img").remove();

    var verticalList = $(this).closest(".product_container").find("ul.vertical li");
    if(verticalList.length>0){
        for(var i = 0; i < images.length; i++){
            $(verticalList[i]).find("img").attr("src",images[i]+"?t="+(new Date).getTime());
        }
    }

    $(".zoomWindow").each(function(){
        cls = $(this).attr("id").split("_")[0];
        console.log(cls);
        bigImg = $("."+cls).attr("href");
        $(this).find("img").attr("src",bigImg);

    }); 
    

    var url = $(this).data("url");
    var spec_color_id = $(this).data("value");
    var spec_size_id = $(this).closest("table.spec_bar").find(".size.selected").data("value");

    var params = { spec_values : [spec_size_id,spec_color_id] };

    getPrice(this,url,params);


    return false;
  });

  $(".spec_bar a.size").live("click",function(){
    
    $(this).parent().find("a.size").removeClass("selected");
    $(this).addClass("selected");
    $(this).closest("td").find(":hidden").val($(this).data("value"));

    var url = $(this).data("url");
    var spec_size_id = $(this).data("value");
    var spec_color_id = $(this).closest("table.spec_bar").find(".color.selected").data("value");

    var params = { spec_values : [spec_size_id,spec_color_id] };

    getPrice(this,url,params);

    return false;
  });


  $(".spec_bar .number_select").live("click",function(){
    $(this).parent().find("ul.number_dropdown").show();
    return false;
  });

  $(".spec_bar ul.number_dropdown").live("mouseleave",function(){
    $(this).hide();
  });

  $(".spec_bar ul.number_dropdown li").live("click",function(){
    // $(this).parent().find("a.number_select").text($(this).text());
    $(this).parents(".number_container").find("a.number_select").text($(this).text());
    $(this).parents(".number_container").find("input.hidden_number").val($(this).text());
    $(this).parent().hide();
  });

  // $(".see_more").live("click",function(){
  //   // $(".drawer").animate()
  //   // cSubpage = $('.drawer');
  //   // cSubpage.animate({ left: '0%'}, 400, function() { });
  //   // $(".left_arrow").show();
  //   // cScrolltop = $(window).scrollTop();
  //   var meta_info = $(this).parents(".meta_info");
  //   var more = meta_info.find(".more");
  //   var brand = meta_info.find(".brand");
  //   var size_helper = meta_info.find(".size_helper");

  //   if($(this).hasClass("actived")) {
  //     $(this).removeClass("actived");
  //     size_helper.removeClass("actived");
  //     meta_info.animate({ top: '20%'}, 400, function() { });
  //     more.slideUp();
  //     brand.slideDown();
  //   } else {
  //     $(this).addClass("actived");
  //     size_helper.addClass("actived");
  //     meta_info.animate({ top: '6%'}, 400, function() { });
  //     more.slideDown();
  //     brand.slideUp();
  //   }
  //   return false;
  // });

  $(".see_info").live("click",function(){
    var brand = $(".brand");
    var meta_info = $(".meta_info");
    var description = $(".description");
    var more = meta_info.find(".more");
    var size_helper = meta_info.find(".size_helper");

    // console.log(brand);
    brand.animate({ top: '10px'}, 400, function() { });
    description.animate({ top: '120px', opacity: '0'}, 400, function() { });
    meta_info.animate({ top: '120px', opacity: '1'}, 400, function() { });


    // if($(this).hasClass("actived")) {
    //   $(this).removeClass("actived");
    //   size_helper.removeClass("actived");
    //   meta_info.show();
    //   meta_info.animate({ top: '20%'}, 400, function() { });
    //   more.slideUp();
    //   brand.slideDown();
    // } else {
    //   $(this).addClass("actived");
    //   size_helper.addClass("actived");
    //   meta_info.show();
    //   meta_info.animate({ top: '6%'}, 400, function() { });
    //   more.slideDown();
    //   brand.slideUp();
    // }
    return false;
  });

  $('html').click(function(e) {
    if( !$(e.target).parents().hasClass('popover') ) {
      $(".size_helper, .custom, .semi_custom").popover('hide');
    }
  });

  $('.add_to_cart').live("click",function(){

     if($(this).hasClass("sold-out")){
        alert("该商品已经售完!");
        return false;
    }

     // var spec_type_size =  $("#specs_container").attr("spec-type-size")*1;
     //  if($("#specs_container input:hidden[value!='']").length != spec_type_size){
     //    $("#cart_msg").text("请您选择您要购买的商品信息 ! ");
     //    return false;
     //  }

    if($(this).hasClass("login")) return false;
    $(".size_helper, .semi_custom").popover('hide');
    $(this).closest("form").submit();

    cScrolltop = $(window).scrollTop();
    return false;
  });

  $('#cart').on('hidden', function () {
    cScrolltop = null;
  });

  $('#mini_items .jcarousel-skin-tango, #btm_items .jcarousel-skin-tango, #more_products .jcarousel-skin-tango').jcarousel({
    // wrap: 'both',
    scroll: 5
    // initCallback: mycarousel_initCallback,
  });

  // $("#new_look #more_products .jcarousel-skin-tango").jcarousel({
  //   scroll: 5
  // });

  $('#more_arrivals .jcarousel-skin-tango').jcarousel({
    // wrap: 'both',
    scroll: 3
    // initCallback: mycarousel_initCallback,
  });
});

function loadProductInfo(productId) {

      // Init Product Gallery 
      var pg = $(productId + ' .jcarousel-skin-tango').jcarousel({
            // wrap: 'both',
            scroll: 1,
            // initCallback: mycarousel_initCallback,
            buttonNextHTML: null,
            buttonPrevHTML: null,
            itemVisibleInCallback: {
                  onAfterAnimation: function(c, o, i, s) {
                      --i;
                      jQuery(productId + ' .gallery_nav li').removeClass('selected');
                      jQuery(productId + ' .gallery_nav li:eq('+i+')').addClass('selected');
                  }
            }
      });

      $(productId + ' .gallery_nav li').bind('click', function(){
            pg.data('jcarousel').scroll(jQuery.jcarousel.intval($(this).text()), false);
            $(productId + ' .gallery_nav li').removeClass('selected');
            $(this).addClass('selected');

            $(productId + ' .paddle').removeClass('disabled');
            if ($(this).text() == '1') {
              $(productId + ' .paddle.pl').addClass('disabled');
              // $(productId + ' .paddle.pl .paddle_img').hide();
            } else if ($(this).text() == '4') {
              $(productId + ' .paddle.pr').addClass('disabled');
              // $(productId + ' .paddle.pr .paddle_img').hide();
            }
            
            return false;
      });

      $(productId + ' .paddle').mouseenter(function(){
            $(productId + ' .paddle').each(function(){
              if (!$(this).hasClass('disabled')) {
                $(this).find('.paddle_img').show();
              }
            });
      }).mouseleave(function(){
            // $(productId + ' .paddle').find('.paddle_img').hide();
      });

      $(productId + ' .paddle').bind('click', function() {
      
            if ($(this).hasClass('pl')) {
              pg.data('jcarousel').prev();
            } else {
              pg.data('jcarousel').next();
            }

            if (pg.data('jcarousel').first ==1 && $(this).hasClass('pl')) {
              $(productId + ' .paddle.pl').addClass('disabled');
              // $(productId + ' .paddle.pl .paddle_img').hide();
            } else if (pg.data('jcarousel').first ==4 && $(this).hasClass('pr')) {
              $(productId + ' .paddle.pr').addClass('disabled');
              // $(productId + ' .paddle.pr .paddle_img').hide();
            } else {
              $(productId + ' .paddle').removeClass('disabled');
              // $(productId + ' .paddle .paddle_img').show();
            }

            return false;
      });

      // Init Product Detail info Accordion 
      $(productId + " .more" ).accordion({
        event: "click hoverintent",
        heightStyle: "content"
      });


      $(productId + " .size_helper").popover({
        placement: 'top',
        html: true,
        trigger: 'manual',
        title: '尺寸说明',
        container: 'body',
        content: function() {
          return $(productId + " .mesure_detail").html();
        }
      }).click(function(){
        
        $(".custom, .semi_custom").popover('hide');
        if ($(productId + " .see_more").hasClass("actived")) {
          $(productId + " .see_more").click();
        }
        $(this).popover('show');

        return false;
      });

      // $(productId + " .market_price").tooltip({placement: 'bottom'});
      $(productId + " .color").tooltip({placement: 'bottom'});
      $(productId + " .size").tooltip({placement: 'bottom'});

      $(productId + " .custom").popover({
        placement: 'top',
        html: true,
        trigger: 'manual',
        title: '定制提示',
        content: function() {
          return $(productId + " .custom_tip").html();
        }
      }).click(function(){
        var url = $(this).data("url");
        var spec_size_id = $(this).data("value");
        var spec_color_id = $(this).closest("table.spec_bar").find(".color.selected").data("value");
        var params = { spec_values : [spec_size_id,spec_color_id] };
        getPrice(this,url,params);
        
        $(this).popover('show');
        $(".size_helper, .semi_custom").popover('hide');
        return false;
      });

      $(productId + " .semi_custom").popover({
        placement: 'top',
        html: true,
        trigger: 'manual',
        title: '请输入你的信息',
        content: function() {
          return $(productId + " .semi_custom_form").html();
        }
      }).click(function(){
        $(this).popover('show');
        $(".size_helper, .custom").popover('hide');
        $(this).parent().find("a.size").removeClass("selected");
        $(this).addClass("selected");
        $(this).closest("td").find("input[name='product[specs][]']").val($(this).data("value"));
        
        var url = $(this).data("url");
        var spec_size_id = $(this).data("value");
        var spec_color_id = $(this).closest("table.spec_bar").find(".color.selected").data("value");
        var params = { spec_values : [spec_size_id,spec_color_id] };
        getPrice(this,url,params);

        return false;
      });


      $(productId + " .spec .popover select").live("change",function(){
          var correspondVal = $(this).data("corresponding");
          var val = $(this).val();
          var target = productId + " .semi_custom_form select[data-corresponding='"+correspondVal+"']";
          $(target).find("option:selected").removeAttr("selected");
          $(target).find("option[value='"+val+"']").attr("selected",true);
      });
};

/*===== FOR jQuery accordion =====*/

var cfg = ($.hoverintent = {
    sensitivity: 7,
    interval: 100
});

$.event.special.hoverintent = {
    setup: function() {
        $( this ).bind( "mouseover", jQuery.event.special.hoverintent.handler );
    },
    teardown: function() {
        $( this ).unbind( "mouseover", jQuery.event.special.hoverintent.handler );
    },
    handler: function( event ) {
        var that = this,
            args = arguments,
            target = $( event.target ),
            cX, cY, pX, pY;

        function track( event ) {
            cX = event.pageX;
            cY = event.pageY;
        };
        pX = event.pageX;
        pY = event.pageY;
        function clear() {
            target
                .unbind( "mousemove", track )
                .unbind( "mouseout", arguments.callee );
            clearTimeout( timeout );
        }
        function handler() {
            if ( ( Math.abs( pX - cX ) + Math.abs( pY - cY ) ) < cfg.sensitivity ) {
                clear();
                event.type = "hoverintent";
                // prevent accessing the original event since the new event
                // is fired asynchronously and the old event is no longer
                // usable (#6028)
                event.originalEvent = {};
                jQuery.event.handle.apply( that, args );
            } else {
                pX = cX;
                pY = cY;
                timeout = setTimeout( handler, cfg.interval );
            }
        }
        var timeout = setTimeout( handler, cfg.interval );
        target.mousemove( track ).mouseout( clear );
        return true;
    }
};

//==============Get Price========
function getPrice(obj,url,params){
    if (!$(obj).hasClass("logined")) return;
    $.get(url,params,function(res){
        $(obj).closest("form").find(".name_and_price .price .georgia").html("￥" + res.price + "&nbsp;&nbsp;&nbsp;\n");
        if(res.store > 0){
          $(".add_to_cart").removeClass("sold-out");
        }else{
          $(".add_to_cart").addClass("sold-out");
        }
    });
}