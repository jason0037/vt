define("common/wx/verifycode.js", [ "widget/verifycode.css", "tpl/verifycode.html.js" ], function(e, t, n) {
"use strict";
function r(e, t) {
var n = this;
this.$dom = $(e).html(i).addClass("verifycode"), this.$img = this.$dom.find("img"), this.$null = this.$dom.find(".jsVerifyNull"), this.$error = this.$dom.find(".jsVerifyError"), this.$input = this.$dom.find("input"), this.$dom.find("a").click(function(e) {
n.refresh();
}), this.$img.click(function(e) {
n.refresh();
}), this.$input.keyup(function(e) {
if (n.$input.val().trim().length > 0) {
n.$null.hide(), n.$error.hide();
var r = "which" in e ? e.which : e.keyCode;
r == 13 && t && t($(this).val());
} else n.$null.show();
}), this.refresh();
}
e("widget/verifycode.css");
var i = e("tpl/verifycode.html.js"), s = "/cgi-bin/verifycode?r=";
r.prototype = {
val: function() {
return this.$null.hide(), this.$input.val() == "" && this.$null.show(), this.$input.val();
},
focus: function() {
return this.$input.focus();
},
err: function() {
return this.$error.show();
},
refresh: function() {
this.$img.attr("src", s + +(new Date)), this.$input.val(""), this.$error.hide(), this.$null.hide();
}
}, n.exports = r;
});