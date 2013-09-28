//= require jquery.ui.datepicker
//= require jquery.ui.slider
//= require jquery-ui-timepicker-addon
//= require jquery-ui-sliderAccess

$(document).ready(function(){
  $(".edit-time").bind("click",function(){
      var url = $(this).data("url");
      var timeHolder =  $(this).prev(".time-holder");
      var time = timeHolder.data("time");
      var timeInput = '<input type="text" class="input-medium publish_at" value="'+time+'" />';
      timeHolder.replaceWith(timeInput);
      
      window.setTimeout(function(){
            $(".publish_at").datetimepicker({
                dateFormat: "yy-mm-dd",
                timeFormat: "hh:mm:ss",
                showSecond: true,
                onClose:function(datetime){

                        $(this).replaceWith(timeHolder.text(datetime).attr("data-time",datetime));
                        var csrf_token = $('meta[name=csrf-token]').attr('content');
                        var csrf_param = $('meta[name=csrf-param]').attr('content');
                        var data = {
                          "utf8":"✓",
                          "published_at":datetime
                         };
                        data[csrf_param] = csrf_token;

                        $.post(url,data,function(res){
                            //Todo:
                        });
                }
            });
            window.setTimeout(function(){
                $(".publish_at").focus();
            },2);
      },1);
  });

$(".dialog").bind("click",function(){
    var url = $(this).data("url");
    var args = ["dialogHeight=200px","dialogWidth=400px","dialogLeft=50%","center=1"].join(";")
    window.showModalDialog(url,args);
 });

  
  
  $(".position_selector").live("change", function() {
    var sel = $(this);
    $.ajax({
      type: 'post',
      url:'/admin/topics/set_position',
      data:{position_id:sel.val(), id:sel.attr('id').replace('ps','')},
      dataType: 'json',
      error: function(request) {
        alert("无法设置排序，请稍候再试!");
      },
      success: function(data) {
        if (data['article_prev_id'] != null && data['article_prev_id'] != 0) {
          $("#ps"+data['article_prev_id']).val('');
          console.log($("#ps"+data['article_prev_id']));
        }
        alert("成功设置排序");
      }
    });
  });

  $(".delete-page").live("click",function(){
      $(this).prev("textarea").remove();
      $(this).remove();
      return false;
  });

  $("#add_page").live("click",function(){
      $(this).parent("div").before('<span>'
                         +'<textarea class="span6 page-area" name="imodec_topic[pages][]" rows="5"></textarea>'
                         +'<a href="#" class="delete-page">X</a>'
                         +'</span>');
      return false;
  });

  
  $(".topic-kind").change(function(){
      var val = $(this).val();
      if(val=="page"){
        $("#page-bodies").show();
        $("#cke_imodec_topic_body").hide();
      }else{
        $("#page-bodies").hide();
         $("#cke_imodec_topic_body").show();
      }
  });



});