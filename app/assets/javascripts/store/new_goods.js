//= require jquery.countdown
//= require jquery.jqzoom-core


$(document).ready(function(){

  // $("#search_btn").bind("click",function(){
  //   var key = $.trim($("#search_input").val());
  //   if(key==''){
  //     $("#search_input").focus();
  //   }else{
  //     window.location.href = "/gallery-index-.html?scontent=n," + key;
  //   }
  // });
  // $("#search_input").bind("keydown",function(e){
  //   if(e.keyCode == 13) $("#search_btn").click();
  // });

  $(".custom-save").live("click",function(){

    var data = { custom_values:[] },spec_item_id,value;

    var url = $(this).data("url"),method = $(this).data("method");
    
    $(this).closest("div.popover-content").find("ul.good_spec_items li").each(function(){
      spec_item_id = $(this).find("[name='product[customs][][spec_item_id]']").val();
      value = $(this).find("[name='product[customs][][value]']").val();
      data.custom_values.push({spec_item_id:spec_item_id,value:value});
    });
    var self = this;
    $.ajax(url,{
      type:method,
      data:data,
      success:function(res){
        $(self).closest("td").find(".semi_custom").popover('hide');
      }
    });
  });

  var deadline = parseInt($("#clock").attr("deadline"),10);
  $('div#clock').countdown(deadline, function(event) {
    $this = $(this);
    switch(event.type) {
          case "seconds":
          case "minutes":
          case "hours":
          case "days":
            $this.find('span#'+event.type).html(event.value);
            break;
          case "finished":
            $this.fadeTo('slow', .5);
            break;
    }
    });

  
  $("#product").on("click",'.cs_helper',function(){
      var chat = $("#live800iconlink").attr("onclick");
      if(!!!chat) return;
      var link = chat.match(/'([^']+)'/)[1];
      window.open(link);
  });

  $(".products_nav .prev_item").bind("click",function(){
        var curItem = $("#products .products_nav li a.selected").parent("li");
        var prevItem = curItem.prev();
        if(prevItem.hasClass("first")) return;
        prevItem.find("a").trigger("click");
  });

  $(".products_nav .next_item").bind("click",function(){
        var curItem = $("#products .products_nav li a.selected").parent("li");
        var next_item = curItem.next();
        if(next_item.hasClass("last")) return;
        next_item.find("a").trigger("click");
  });

  $("#products .products_nav li a.product_link").bind('click',function(){

        $("#products .products_nav li a").removeClass("selected");
        $(this).addClass("selected");

        $("#products .single-loader").show();
        return true;
  });

  $("#submit_cmt").click(function(){
    var cmt = $.trim($("#comment_content").val());
    if(cmt.length == 0){
      alert("请填写评论内容");
      $("#comment_content").focus();
      return false;
    }

    var url = $(this).data("url");
    var goodsId = $(this).data("goods");
    var memberId = $(this).data("member");
    var cmt_type = $(this).data("type");
    var authenticity_token = $("meta[name='csrf-token']").attr("content");

    var params = {
      member_id: memberId,
      content: cmt,
      commentable_id: goodsId,
      commentable_type: cmt_type
    };
    $.post(url,{authenticity_token:authenticity_token,comment:params});
    return false;
  });


  $("#specs_container").on("click",".spec-value",function(){
    $("#cart_msg").empty();

    if($(this).hasClass("image") && $("#specs_container .spec-value[data-images]").length > 1){
       var images = $(this).data("images").split(/\s+/);
       var jcarouselList = $(this).closest(".product_container").find("ul.jcarousel-list li.jcarousel-item");
       if(jcarouselList.length>0){
            for(var i = 0; i < images.length; i++){
                $(jcarouselList[i]).find("img").attr("src",images[i]+"?t="+(new Date).getTime());
                $(jcarouselList[i]).find("a").attr("href",images[i]);
            }
       }
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
    }

    $(this).closest('.spec-item').find(":hidden").val($(this).data("value"));
    $(this).closest('.spec-values').find(".spec-value").removeClass("selected");
    $(this).addClass("selected");
    var spec_values = []
    var $specs = $("#specs_container");
    $specs.find("input[name='product[specs][]']").each(function(){
       var tmp = $(this).val();
       if(tmp.length>0){
          spec_values.push(tmp);
       }
    });

    var url = $specs.attr("property-url");
    var spec_type_size = $specs.attr("spec-type-size")*1;
    if(spec_values.length ==  spec_type_size){
      $.get(url,{spec_values: spec_values}, function(res){
          $("#product_store").text(res.store);
          $("#product_price").text(res.price);

          $("#store").empty();
          if(res.store>0){
             $("#add_to_cart").removeClass("sold-out");
             for(var i=1;i <= res.store; i++){
                $("#store").append('<option value="'+i+'">'+i+'</option>');
             }
          }else{
            // no store
            $("#store").append('<option value="'+0+'">'+0+'</option>');
            $("#add_to_cart").addClass("sold-out");
          }
      });
    }
    return false;
  });

  
});
