define("common/wx/slider.js", [], function(e, t, n) {
"use strict";
var r = {
titleId: "",
titleTag: "",
contentId: "",
contentTag: "",
prevContainer: "",
nextContainer: "",
perView: 1,
className: "current",
eventType: "mouseover",
initIndex: 0,
timeLag: 300,
funcInit: function() {},
funcTabInit: function() {},
func: function() {},
onPage: function() {},
auto: !0,
autoKeep: !0,
autoTimes: 1e3,
autoLag: 5e3,
fadeLag: 50,
fadeTimes: 500,
initSpeed: 100,
effect: "none",
width: 0,
height: 0,
backAttr: "back_src",
isLoadInit: !0,
funcTabChange: function() {}
}, i = function(e) {
this.opt = $.extend(!0, {}, r, e), this._g = {
total: 0,
pageTotal: 0,
current: 0,
autoCount: 0,
isInit: !0,
intr: null,
autoIntr: null,
_imgs: [],
_cont: [],
_tabs: []
}, this._init();
};
i.prototype = {
_init: function() {
var e = this, t = e.opt, n = e._g;
(t.width == 0 && t.effect == "scrollx" || t.height == 0 && t.effect == "scrolly") && (t.effect = "none"), t.contentId && (e.oContent = $("#" + t.contentId), e.oContent.find(t.contentTag).each(function() {
var e = this;
switch (t.effect) {
case "none":
e.style.display = "none";
break;
case "scrollx":
e.style.width = t.width + "px", e.style.styleFloat = e.style.cssFloat = "left", e.style.visibility = "hidden";
break;
case "scrolly":
e.style.height = t.height + "px", e.style.visibility = "hidden";
break;
case "fade":
e.style.display = "none", e.style.position = "absolute", e.style.left = 0, e.style.top = 0;
}
n._cont.push(e), t.funcInit(n.total++, $(e));
}), t.auto === !0 && e.oContent.mouseenter(function() {
clearInterval(n.autoIntr);
}).mouseleave(function() {
t.autoKeep === !0 && e._setAuto();
}));
if (t.titleId) {
var r = e.oTitle = $("#" + t.titleId), i = 0;
r.find(t.titleTag).each(function() {
var e = $(this);
t.funcTabInit(i, e), e.attr("index", i++), n._tabs.push(e);
}), n.total = i, r.on(t.eventType, t.titleTag, function(r) {
var i = $(this), s = i.attr("index") * 1;
clearInterval(n.autoIntr), s != n.current && (n.intr = setTimeout(function() {
t.funcTabChange(s, t), e._setEffect(s);
}, t.timeLag));
}).on("mouseout", t.titleTag, function(r) {
clearTimeout(n.intr), t.auto && t.autoKeep && e._setAuto();
});
}
n.pageTotal = Math.ceil(n.total / t.perView), n.current = t.initIndex, n.autoTotal = t.autoTimes * n.pageTotal - 1, e._setEffect(n.current), t.auto && e._setAuto(), t.prevContainer && $(t.prevContainer).click(e._showPrev), t.nextContainer && $(t.nextContainer).click(e._showNext), n.isInit = !1;
},
_setAuto: function() {
var e = this, t = e.opt, n = e._g;
clearInterval(n.autoIntr), n.autoIntr = setInterval(function() {
n.autoCount >= n.autoTotal ? clearInterval(n.autoIntr) : (e._setEffect(n.current + 1 >= n.pageTotal ? 0 : n.current + 1), n.autoCount++);
}, t.autoLag);
},
_setEffect: function(e) {
function t(t) {
var n = e - o.current < 0 ? -1 : 1, r = e * t, i = (e - n) * t, u = o._cont[0];
return o.current == 0 && (u.style.position = "static"), o.current + 1 == o.total && e == 0 && (n = 1, r = (o.current + 1) * t, i = o.current * t, u.style.position = "relative", s.effect == "scrollx" ? u.style.left = r + "px" : u.style.top = r + "px"), {
t: 0,
distance: n * t,
end: r,
here: i
};
}
function n(e) {
var t = e.here, n = e.distance, r = s.fadeTimes, i = e.t / r - 1;
return parseInt(-n * (i * i * i * i - 1) + t, 10);
}
function r(e) {
if (e >= o._cont.length) return;
s.contentId && !o._imgs[e] && (o.isInit == 0 || o.isInit == 1 && s.isLoadInit == 1) && ($(o._cont[e]).find("img").each(function() {
var e = $(this);
e.attr("src", e.attr(s.backAttr));
}), o._imgs[e] = !0), s.contentId && (o._cont[e].style.display == "none" && (o._cont[e].style.display = "block"), o._cont[e].style.visibility == "hidden" && (o._cont[e].style.visibility = "visible"));
if (s.titleId) {
for (var t = 0, n = o._tabs.length; t < n; t++) t != e && o._tabs[t].removeClass(s.className);
o._tabs[e].addClass(s.className), o._tabs[e].show();
}
s.func(e);
}
var i = this, s = i.opt, o = i._g, u = i.oContent[0];
if (e >= o._cont.length) return;
if (!s.contentId) {
r(e), o.current = e;
return;
}
if (o.isInit) {
switch (s.effect) {
case "scrollx":
u.style.position = "relative", u.style.width = (o.total + 1) * s.width + "px", u.style.left = -o.current * s.width + "px";
break;
case "scrolly":
u.style.position = "relative", u.style.top = -o.current * s.height + "px";
break;
case "fade":
u.style.position = "relative";
}
for (var a = 0; a < s.perView; a++) e + a < o.total && r(e + a);
s.onPage(e), o.current = e;
} else {
var f = Math.floor(s.fadeTimes / s.fadeLag), l = null, c = 0;
if (s.globeFadeIntr) {
switch (s.effect) {
case "fade":
o._cont[o.current].style.zIndex = 0, o._cont[e].style.zIndex = 1, o._cont[o.current].style.filter = "alpha(opacity=0)", o._cont[o.current].style.opacity = 0, o._cont[e].style.filter = "alpha(opacity=1)", o._cont[e].style.opacity = 1, o.current = e;
}
clearInterval(s.globeFadeIntr);
}
s.globeFadeIntr = null;
switch (s.effect) {
case "none":
for (var a = 0; a < s.perView; a++) {
var h;
(h = o.current * s.perView + a) < o.total && (o._cont[h].style.display = "none"), (h = e * s.perView + a) < o.total && r(h);
}
s.onPage(e), o.current = e;
break;
case "scrollx":
var p = t(s.width);
r(e), s.globeFadeIntr = l = setInterval(function() {
c++ >= f ? (clearInterval(l), s.globeFadeIntr = null, u.style.left = -p.end + "px", o.current = e) : (u.style.left = -n(p) + "px", p.t = p.t < s.fadeTimes ? p.t + s.fadeLag : s.fadeTimes);
}, s.fadeLag);
break;
case "scrolly":
var d = t(s.height);
r(e), s.globeFadeIntr = l = setInterval(function() {
c++ >= f ? (clearInterval(l), s.globeFadeIntr = null, u.style.top = -d.end + "px", o.current = e) : (u.style.top = -n(d) + "px", d.t = d.t < s.fadeTimes ? d.t + s.fadeLag : s.fadeTimes);
}, s.fadeLag);
break;
case "fade":
r(e), s.globeFadeIntr = l = setInterval(function() {
if (c++ >= f) clearInterval(l), s.globeFadeIntr = null, o._cont[o.current].style.zIndex = 0, o._cont[e].style.zIndex = 1, o.current = e; else {
var t = c / f;
o._cont[o.current].style.filter = "alpha(opacity=" + (1 - t) * 100 + ")", o._cont[o.current].style.opacity = 1 - t, o._cont[e].style.filter = "alpha(opacity=" + t * 100 + ")", o._cont[e].style.opacity = t;
}
}, s.fadeLag);
}
}
},
_showPrev: function(e) {
var t = this, n = t._g;
clearInterval(n.autoIntr), t._setEffect(n.current - 1 < 0 ? n.pageTotal - 1 : n.current - 1);
},
_showNext: function(e) {
var t = this, n = t._g;
clearInterval(n.autoIntr), t._setEffect(n.current + 1 >= n.pageTotal ? 0 : n.current + 1);
},
destroy: function() {
self.oTitle.off(), self.oContent.off(), self.prevContainer.off(), self.nextContainer.off();
}
};
var s = function(e, t) {
if (t.indexOf) return t.indexOf(e);
for (var n = t.length; n--; ) if (t[n] === e) return n * 1;
return -1;
};
return i;
});define("home/index.js", [ "common/wx/slider.js" ], function(e, t, n) {
"use strict";
var r = e("common/wx/slider.js");
(function() {
function e() {
new r({
fadeTimes: 1e3,
width: $("#slider_container li").width(),
effect: "scrollx",
initIndex: 0,
titleId: "slider_title",
titleTag: "li",
contentId: "slider_container",
contentTag: "li"
});
}
e();
})();
});