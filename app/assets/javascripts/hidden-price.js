$(document).ready(function(){
    var logged = !!document.cookie.match(/MEMBER=[a-zA-Z-0-9-]+;/);
    if (logged) {
      return;
    }
    $(".require-login").each(function() {
      	$(this).empty().html("<a href=\"javascript:void();\" style=\"color:red;\" class=\"vip-only login\">  会员专享 </a>");
    });
});