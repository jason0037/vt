define("common/wx/process.js", [ "widget/processor.css", "tpl/process.html.js" ], function(e, t, n) {
"use strict";
function r(e) {
e && e.container && e.data && (this.$dom = $(e.container).html($(template.compile(i)({
data: e.data
}))), this.go(e.index));
}
e("widget/processor.css");
var i = e("tpl/process.html.js");
$.fn.setClass = function(e) {
this.attr("class", e);
}, r.prototype = {
go: function(e) {
e = e || 0;
var t = this.$dom.find("li");
t.each(function(n, r) {
$(this).removeClass("prev").removeClass("current"), n < e ? $(this).setClass("prev") : n == e && $(this).setClass("current"), n == t.length - 2 ? $(this).addClass("size1of" + (t.length - 1) + " no_extra") : n == t.length - 1 ? $(this).addClass("size1of" + (t.length - 1) + " last") : $(this).addClass("size1of" + (t.length - 1));
});
}
}, n.exports = r;
});