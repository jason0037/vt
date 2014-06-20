
(function(pageContext, util) {
	
    _.templateSettings = {
        variable: "bean",
        evaluate: /#%([\s\S]+?)%#/g,
        interpolate: /#%=([\s\S]+?)%#/g,
        escape: /#%-([\s\S]+?)%#/g
    };
	
    var itemListTemplate = _.template($("#item_list_tpl").html());
    var $main = $(".gridItem");
    var $more = $(".more_btn");
    var barrier = util.createBarrier($more);
    var query = $more.data("query");
    var pageSize = $more.data("pagesize");
    var imageSelector = "img.j_item_image";
    
    function loadMore() {
        // Avoid loading too many items in a page. 
        if (parseInt($more.attr("data-page")) == 50) {
            return;
        }

        if (!barrier.isAvailable()) {
            return;
        }

        if (util.isElementInViewport($more)) {
            barrier.acquireLock();
            $more.html('<img src="view/touch/images/common/loading-big.gif" alt="loading" />加载中');
            var nextPage = parseInt($more.attr("data-page")) + 1;
            fetch(nextPage);
        }
    }

    function fetch(page) {
        $.ajax({
            url: "ajaxapi-itemlist.html?s=" + new Date().getTime(),
            data: {page: page, pageSize: pageSize, query: query},
            dataType: "json",
            success: function(itemList) {
                handleSuccess(itemList, page);
            },
            error: function(xhr, status, error) {
                handleError();
            }
        });
    }

    function handleSuccess(itemList, page) {
        if (itemList && itemList.length > 0) {
            appendNewPage(itemList, page);
            updateNewPageStock(itemList);
            barrier.releaseLock();
        }
        else {
            $more.html("^_^，亲，没有更多了");
            $(window).off("scroll.loadMore");
            barrier.terminate();
        }
    }

    function appendNewPage(itemList, page) {
       var bean = {
       	    page: page,
       	    itemList: itemList, 
       	    brand_id: pageContext.brand_id,
       	    filter_size: pageContext.filter_size,
       	    efilter_size: pageContext.efilter_size
       };
       $main.append(itemListTemplate(bean));
       $more.html("查看更多商品").attr("data-page", page);
       var selector = imageSelector + ".pg" + page;
       $(selector).lazyload({
           effect: "fadeIn",
           effect_speed: 100
       });
    }

    function updateNewPageStock(itemList) {
       var buffer = new Array();
       for (var i = 0; i < itemList.length; i++) {
           buffer.push(itemList[i].product_id);
       }
       var itemIds = buffer.join(",");
       updateStock(itemIds, pageContext.is_old);
    }

    function handleError() {
        $more.html("网络延时，请重试");
        barrier.releaseLock();
    }
    
    function updateStock(itemIds, is_old) {
    	if (!itemIds) {
    		return;
    	}
    	
    	var stockUrl = "http://stock.vipshop.com/list/?mid=" + encodeURIComponent(itemIds);
    	if (is_old) {
    		stockUrl = stockUrl + "&id_old=" + is_old;
    	}
    	
    	$.ajax({
    		url: stockUrl,
            dataType: "jsonp",
            jsonpCallback: "handleStock"
    	});
    }

    var handleStock = window.handleStock = function(data) {
    	// Do basic validation
    	if (!data) {
    		return;
    	}
    	
    	if (!data.sold_out && !data.sold_chance) {
    		return;
    	}
    	
    	// Populate stock not available id map
    	var idMap = {};
    	var i;
    	if (data.sold_out) {
    	    var soldOutItems = data.sold_out.split(",");
    	    for (i = 0; i < soldOutItems.length; i++) {
    	      	 idMap["mid_" + soldOutItems[i]] = 1;
    	    }
    	}
    	
    	if (data.sold_chance) {
    		var soldChanceItems = data.sold_chance.split(",");
    	    for (i = 0; i < soldChanceItems.length; i++) {
    	      	 idMap["mid_" + soldChanceItems[i]] = 1;
    	    }
    	}
    	
    	// Actual processing
        // Only select the current page items.
        var page = $(".more_btn").data("page");
        var selector = ".rs-item.pg" + page; 
        $(selector).each(function(index) {
     	    var $item = $(this);
     	    var itemId = $item.attr("data-mid");
     	    
     	    // Stock not available
     	    if (idMap["mid_" + itemId]) {
     		     // Add sold out tag
     		     if (!isMarkAsSoldout($item)) {
     			     $item.find(".pic").append("<span class=\"seldout\"></span>");
     		     }
     	     }
     	     // Stock available
     	     else {
     		     // Clear sold out tag
     		     if (isMarkAsSoldout($item)) {
     			     $item.find(".seldout").remove();
     		     }
     	     }
        });
    };

    function isMarkAsSoldout($item) {
    	return $item.find(".seldout").length > 0;
    }
    
    function init() {
        // Lazy load images.
        $(imageSelector).lazyload({
            effect: "fadeIn",
            effect_speed: 100
        });

        // Fetch real time stock.
        // TODO pass in the right arguments (is_old).
        updateStock(pageContext.itemIds, pageContext.is_old);
        
        // No need to bind scroll handler if it's already the last page.
        if ($(".rs-item").length < pageSize) {
            $more.html("^_^，亲，没有更多了");
        }
        // Bind scrolling event.
        else {
            var throttledFn = _.throttle(loadMore, 80);
            $(window).on("scroll.loadMore", throttledFn);
        }
    };
    var isSaleTime = {
		init: function(){
			var dom = {
				elem: $('[data-saleBrand="true"]'),
				container: 'span.J-time',
				startTime: $('[data-saleBrand="true"]').attr('data-saletime'),
				unitFormat:{
					"day": true,
					"hour": true,
					"min": true,
					"sec": true
				},
				timeStamp: {
					"day": '天',
					"hour": '时',
					"min": '分',
					"sec": '秒'
				},
				halfwayTime: false
			};
			hawk.countDown(dom);
		}
	};
    $(function(){
        init();
		$('[data-shopcart="true"]').length && hawk.runCartTime()
		$('[data-saleBrand="true"]').length && isSaleTime.init();
    });
	
})(pageContext, hawk.util);

var VsmwebEffect = (function() {
	var $thumbList = $('[data-thumbcate="list"]'),
	$dropCate = $('.drop_cate'),
	$cateCate = $('#B_cateWrap'),
	$listCate = $('#B_listWrap'),
	B = {
		slidePageDown: function() {
			this.elem.next().fadeIn('fast').parent().addClass('active');
			if (this.elem.parent().next().hasClass('active')) {
				var t = this.elem.parent().next().children().filter('a'),
				adom = {
					elem: t,
					direction: t.attr('data-dropmen'),
					child: t.next().children().find('h2')
				};
				B.slidePageRight.call(adom)
			}
		},
		slidePageUp: function() {
			this.elem.next().fadeOut('fast').parent().removeClass('active')
		},
		slidePageLeft: function() {
			var slideWidth = this.elem.next().outerWidth(true),
			slideTop = parseInt(this.elem.next().css('top'), 10),
			slideAnimateIn = {};
			if (this.elem.next().is(':visible')) return;
			switch (this.direction) {
			case 'left':
				this.elem.next().css({
					left:
					'auto',
					right: '-' + slideWidth + 'px',
					height: $(document).outerHeight()
				});
				slideAnimateIn['right'] = '+=' + slideWidth;
				break;
			default:
				this.elem.next().css({
					left:
					'-' + slideWidth + 'px',
					right: 'auto'
				});
				slideAnimateIn['left'] = '+=' + slideWidth;
				break
			};
			this.elem.next().show().animate(slideAnimateIn, 'fast').parent().addClass('active');
			if (this.elem.parent().prev().hasClass('active')) {
				var t = this.elem.parent().prev().children().filter('a'),
				adom = {
					elem: t,
					direction: t.attr('data-dropmen'),
					child: t.next().children().find('h2')
				};
				B.slidePageUp.call(adom)
			};
			this.elem.next().undelegate('[data-dropClose="true"]', 'click.drop.close').delegate('[data-dropClose="true"]', 'click.drop.close', B.slidePageBottom);
			document.addEventListener("touchmove", B.touchEvent, false)
		},
		slidePageRight: function() {
			var slideWidth = this.elem.next().outerWidth(true),
			slideAnimateIn = {};
			if (this.elem.next().is(':hidden')) return;
			switch (this.direction) {
			case 'left':
				slideAnimateIn['right'] = '-=' + slideWidth;
				break;
			default:
				slideAnimateIn['left'] = '-=' + slideWidth;
				break
			};
			this.elem.next().animate(slideAnimateIn, 'fast',
			function() {
				$(this).hide()
			}).parent().removeClass('active');
			document.removeEventListener("touchmove", B.touchEvent, false)
		},
		touchEvent: function(e) {
			e.preventDefault()
		},
		slideCateinit: function() {
			var t = $(this),
			dom = {
				elem: t,
				direction: t.attr('data-dropmen'),
				child: t.next().children().find('h2')
			};
			(dom.direction && dom.direction == 'down') ? (dom.elem.next().is(':visible') ? (B.slidePageUp.call(dom)) : (B.slidePageDown.call(dom))) : ((dom.elem.next().is(':visible')) ? (B.slidePageRight.call(dom)) : (B.slidePageLeft.call(dom)))
		},
		slidePageBottom: function() {
			var t = $(this),
			dom = {
				elem: t.parents('.trasp').prev(),
				direction: "left"
			}; (dom.elem.next().is(':visible')) && B.slidePageRight.call(dom)
		},
		slideMenuinit: function() {
			var t = $(this),
			dom = {
				elem: t,
				child: t.children('h2'),
				cartid: t.attr('data-cateid'),
				next: t.parents('.drop_cate').next().children().find('.category')
			};
			if (!dom.child.hasClass('active') && !dom.next.filter('[data-listid="' + dom.cartid + '"]').is(':visible')) {
				dom.child.addClass('active').parent().siblings('li').children('h2').removeClass('active').parents('.drop_cate').next().children().children().children().filter('[data-listid="' + dom.cartid + '"]').show('fast').siblings('.category').hide('fast')
			}
		}
	},
	C = {
		bindwindowCategory: function() {
			var dom = {
				wH: $(window).innerHeight(),
				hH: $('.header').innerHeight(),
				tH: $('.thumb-mode').innerHeight(),
				lE: $('.gridItem').children().filter('dl').length
			};
			if (window.orientation == 0 || window.orientation == 180) { (dom.lE) ? C.categoryStyle(dom, 0.76) : (C.categoryStyle(dom, 0.50))
			} else if (window.orientation == 90 || window.orientation == -90) {
				C.categoryStyle(dom, 1)
			} else { (dom.lE) ? C.categoryStyle(dom, 0.76) : (C.categoryStyle(dom, 0.50))
			}
		},
		categoryStyle: function(o, dir) {
			$cateCate.css({
				'height': (o.wH - o.hH - o.tH) * dir + 'px'
			});
			$listCate.css({
				'height': (o.wH - o.hH - o.tH) * dir + 'px'
			});
			$('.drop_bottom').add($('.drop_bottom').children('a')).css({
				top: (o.wH - o.hH - o.tH) * dir,
				height: o.wH - o.hH - o.tH - ((o.wH - o.hH - o.tH) * dir)
			});
			return false
		},
		categoryEvent: function() {
			var vipCatesrcoll = new iScroll('B_cateWrap', {
				checkDOMChanges: true,
				onScrollStart: function() {
					vipCatesrcoll.refresh()
				}
			});
			var vipListsrcoll = new iScroll('B_listWrap', {
				checkDOMChanges: true,
				onScrollStart: function() {
					vipListsrcoll.refresh()
				}
			})
		},
		cateInit: function() { ($cateCate.length > 0) && C.categoryEvent()
		}
	},
	I = {
		bindEvents: function() {
			$thumbList.children().children().filter('a').off('click.made.classify').on('click.asyn.classify', B.slideCateinit);
			$dropCate.children().find('li').off('click.drop.menu').on('click.drop.menu', B.slideMenuinit);
		},
		init: function() {
			I.bindEvents();
			($cateCate.length > 0) && C.bindwindowCategory();
			hawk.download();
		}
	};
	return {
		init: I.init,
		cateInit: C.cateInit
	};
})();

$(function() {
	VsmwebEffect.init();
	VsmwebEffect.cateInit();
});



