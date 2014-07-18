define("regist/regist.js", [ "common/wx/process.js", "common/wx/verifycode.js", "common/wx/Cgi.js", "common/wx/Tips.js", "common/lib/jquery.validate.js", "common/lib/jquery.md5.js" ], function(e, t, n) {
"use strict";
var r = e("common/wx/process.js"), i = e("common/wx/verifycode.js"), s = e("common/wx/Cgi.js"), o = e("common/wx/Tips.js");
e("common/lib/jquery.validate.js"), e("common/lib/jquery.md5.js");
var u = {}, a;
a = new r({
container: "#step",
index: 0,
data: [ "填写基本信息", "邮箱激活", "完善开发者资料" ]
});
var f = "/cgi-bin/register?1=1&", l, c = function() {
function e() {
$("#step1").show().siblings().hide(), l = new i("#verify", function() {
$("#nextBt").trigger("click");
});
var e = $("#baseForm").validate({
rules: {
email: {
required: !0,
email: !0
},
passwd: {
required: !0,
minlength: 6,
maxlength: 12
},
repwd: {
required: !0,
equalTo: "input[name='passwd']"
}
},
messages: {
email: {
required: "请输入邮箱地址",
err: "测试"
},
passwd: {
required: "请输入密码"
},
repwd: {
required: "请再次输入密码",
equalTo: "2次密码输入不一致"
}
}
});
$("#nextBt").click(function(t) {
e.form() && l.val() && s.post({
url: f,
data: {
email: $("input[name='email']").val().trim(),
verify_code: l.val(),
passwd: $.md5($("input[name='passwd']").val().trim())
}
}).callback(function(t) {
t.base_resp.ret == "0" ? (u.email = $("input[name='email']").val().trim(), u.passwd = $.md5($("input[name='passwd']").val().trim()), h.init()) : t.base_resp.ret == "1000" ? (e.showErrors({
email: "邮箱已被占用，请使用未被微信开放平台注册、未被微信公众平台注册、未被微信个人帐号绑定的邮箱"
}), l.refresh()) : t.base_resp.ret == "1001" ? l.err() : t.base_resp.ret == "1026" ? (o.err("该邮箱已绑定到个人微信号，不能再用于注册微信开放平台，请更换其他邮箱"), e.showErrors({
email: "该邮箱已绑定到个人微信号，不能再用于注册微信开放平台，请更换其他邮箱"
})) : t.base_resp.ret == "1027" ? (o.err("该邮箱已注册过微信公众平台帐号，请更换其他邮箱"), e.showErrors({
email: "该邮箱已注册过微信公众平台帐号，请更换其他邮箱"
})) : t.base_resp.ret == "1028" ? (o.err("该邮箱已注册过微信开放平台，不能再用于注册，请更换其他邮箱"), e.showErrors({
email: "该邮箱已注册过微信开放平台，不能再用于注册，请更换其他邮箱"
})) : o.err();
});
});
}
return {
init: e
};
}(), h = function() {
function e() {
a.go(1), $("#step2").show().siblings().hide(), $("#emailTxt").text(u.email);
}
$("#rewrite").click(function(e) {
a.go(0), $("#step1").show().siblings().hide(), l.refresh();
}), $("#reSend").click(function(e) {
s.post({
url: f,
data: u
}).callback(function(e) {
e.base_resp.ret == "0" ? o.suc() : e.base_resp.ret == "-7" ? o.err("发送邮件操作太频繁，请稍后尝试。") : o.err();
});
}), $("#goEmail").click(function(e) {
u.email.split("@").length == 2 && window.open("http://" + t[u.email.split("@")[1]]);
});
var t = {
"foxmail.com": "mail.foxmail.com",
"qq.com": "mail.qq.com",
"vip.qq.com": "mail.qq.com",
"gmail.com": "mail.google.com",
"163.com": "mail.163.com",
"126.com": "mail.126.com",
"188.com": "mail.188.com",
"sina.com": "mail.sina.com",
"sohu.com": "mail.sohu.com",
"yahoo.cn": "mail.cn.yahoo.com",
"yahoo.com.cn": "mail.cn.yahoo.com",
"hotmail.com": "mail.hotmail.com",
"live.com": "mail.live.com"
};
return {
init: e
};
}();
c.init();
});