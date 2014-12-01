(function() {




})(window.Zepto);

 // checkbox设置
function checkbox(e){
    if( e.attr("checked")==false){
       e.attr("checked",'true');
    } else{
        e.removeAttr("checked");
    }
}
//万家地址信息匹配
function choosecity(e){
   for(var i in allcity){
       if(e==allcity[i].name){
           return (allcity[i]).sub[0].name
       }
   }
}
