/*
	dev by yxf 
	----------------------------------------------------------------------------------------
	you need add css 
	.__email-suggest-holder .active{
    		background-color:#555; //selected bgcolor
	}
	-----------------------------------------------------------------------------------------
	*usage example
	$(selector).emailSug({
		emailProviders: ['@163.com','@126.com','@qq.com','@sina.com','@sina.cn','@gmail.com','@hotmail.com','@yahoo.com'],
		sugHolderCss: { backgroundColor: '#222', color:'#bbb' },
		afterSelected:null
	});
*/
(function($){
	$.fn.emailSug = function(options){
		var opts = $.extend({}, $.fn.emailSug.defaults, options);

		var _sugHolderId = "__email_suggest_holder_" + ($(".__email-suggest-holder").length + 1);
		$("body").append("<div class='__email-suggest-holder' id='"+_sugHolderId+"'/>");
		_sugHolder = $("#"+ _sugHolderId);

		var _afterSelectedCallback = opts.afterSelected;

		var self = this;
		var _inputEvent = function(e){
			if(e.target != document.activeElement) return;

			var inputVal = $.trim($(this).val());

			if( opts.sugExceptRule != undefined && opts.sugExceptRule.test(inputVal) ){
				_sugHolder.empty().hide();
				return;
			}
			
			if(inputVal=='' || inputVal.indexOf("@")>-1){
				_sugHolder.empty().hide();
				return;
			}
			
			var inputWidth = $(this).width();
			var inputHeight = $(this).height();
			var InputOffset = $(this).offset();

			var paddingLeft = $(this).css("padding-left");
			var paddingRight = $(this).css("padding-right");
			var paddingTop = $(this).css("padding-top");
			var paddingBottom = $(this).css("padding-bottom");

			var borderLeftWidth = $(this).css("border-left-width");
			var borderRightWidth = $(this).css("border-left-width");
			var borderTopWidth = $(this).css("border-left-width");
			var borderBottomWidth = $(this).css("border-left-width");

			var left = InputOffset.left + "px";
			var top = (InputOffset.top + inputHeight 
				          + parseInt(paddingTop) +  parseInt(paddingBottom)
				          + parseInt(borderTopWidth) +  parseInt(borderBottomWidth)) +"px";
			

			var _width = (inputWidth + parseInt(paddingLeft) + parseInt(paddingRight)
			                     + parseInt(borderLeftWidth)+parseInt(borderRightWidth) )+ "px";

			var _sugItemActiveClass = opts.sugItemActiveClass;
			var _sugHolderCss  = $.extend({ position:'absolute',
								 zIndex: 999999,
								 width: _width,
							 	 left:left,
							 	 top:top
							 	},opts.sugHolderCss);

			_sugHolder.css(_sugHolderCss).empty().show();

			for(var e in opts.emailProviders){
				var email = inputVal + opts.emailProviders[e]
				_sugHolder.append('<p style="overflow: hidden; white-space: nowrap;margin:0px;padding:2px 10px;text-overflow: ellipsis;" >'+email+'</p>');
			}
			_sugHolder.find("p").live("mouseenter",_mouseEnterEvent)
							.live("mouseleave",_mouseEnterEvent)
							.live("click",_itemClickEvent);
		};

		var _keyDownEvent = function(e){

			if(e.keyCode == 13){
				if(_sugHolder.children("p.active").length>0){
					var _activeVal = _sugHolder.children("p.active").text();
					$(this).val(_activeVal);
				}
				
				_sugHolder.empty().hide();
				if(!!_afterSelectedCallback) _afterSelectedCallback.call(null,_activeVal);
			}

			var _sugItem = _sugHolder.find("p");
			if(e.keyCode == 38){//up

				if(_sugItem.hasClass("active")
					&&!_sugItem.first().hasClass("active")){
					var prev = _sugHolder.find("p.active").prev();
					_sugItem.removeClass("active");
					prev.addClass("active");
				}else{
					_sugItem.removeClass("active");
					_sugHolder.find("p:last").addClass("active");
				}

			}

			if(e.keyCode == 40){//down

				if(_sugItem.hasClass("active")
					&&!_sugItem.last().hasClass("active")){
					var next = _sugHolder.find("p.active").next();
					_sugItem.removeClass("active");
					next.addClass("active");
				}else{
					_sugItem.removeClass("active");
					_sugHolder.find("p:first").addClass("active");
				}
			}
		};

		var _mouseEnterEvent = function(e){
			_sugHolder.children("p").removeClass("active");
			$(this).addClass("active");
		}

		var _moustLeaveEvent = function(e){
			_sugHolder.children("p").removeClass("active");
		}

		var _itemClickEvent = function(){
			var _activeVal = $(this).text();
			$(self).val(_activeVal);
			_sugHolder.empty().hide();
			if(!!_afterSelectedCallback){
				_afterSelectedCallback.call(null,_activeVal);
			}
			
		} 

		$(this).live("input",_inputEvent);
		$(this).bind("propertychange",_inputEvent); //ie7,ie8,firefox

		$(this).live("keydown",_keyDownEvent);
		$(this).live("blur",function(){
			// if(_sugHolder.find("p.active").length>0){
			// 	var _activeVal = _sugHolder.find("p.active").text();
			// 	$(self).val(_activeVal);
			// }
			// _sugHolder.empty().hide();
		});
	}

	$.fn.emailSug.defaults = {
		emailProviders: ['@163.com','@126.com','@qq.com','@sina.com','@sina.cn','@gmail.com','@hotmail.com','@yahoo.com'],
		sugHolderCss: { backgroundColor: '#222', color:'#bbb' },
		afterSelected:null
	}

})(jQuery);