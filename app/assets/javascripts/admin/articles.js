
$(document).ready(function(){
  $(".position_selector").live("change", function() {
    var sel = $(this);
    $.ajax({
      type: 'post',
      url:'/admin/articles/set_position',
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
});