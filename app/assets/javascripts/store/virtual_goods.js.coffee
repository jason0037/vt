# =require jquery-ui-1.9.2.custom
# =require jquery-ui-accordion-patch
# = require store/show_map
# = require store/download_coupon
# = require jquery.jqzoom-core

$ ->
  $("#rules_and_addrs" ).accordion({
     event: "click hoverintent",
     heightStyle: "content"
   });
  	
   $("[class^=jqzoom]").jqzoom({
       zoomType: 'standard',
       lens:true,
       preloadImages: false,
       alwaysOn:false,
       zoomWidth: 400,
       zoomHeight: 592,
       preloadText: '正在加载图片...',
       title: false
   });
