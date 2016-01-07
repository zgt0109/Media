$(function(){
  $('form').on('input', '#wx_title', function(){
    $('.warpVMS #preview_title').html($(this).val());
  });

  $('form').on('input', '#wx_summary', function(){
    $('.warpVMS #preview_summary').html($(this).val());
  });
})


this.preview_wx_setting = function(pre_title, pre_summary) {
  var $origin_summary, $origin_title, summary, title;
    title = $("input.activity_name_input");
    summary = $(".activity_summary_input");
    pre_title = $(pre_title);
    pre_summary = $(pre_summary);
    $origin_title = pre_title.text();
    $origin_summary = pre_summary.text();
    pre_title.text(title.val() || pre_title.text());
    pre_summary.text(summary.val() || pre_summary.text());
    title.bind("change", function(event, ui) {
        return pre_title.text(this.value || $origin_title);
    });
    title.bind("keyup", function(event, ui) {
        return pre_title.text(this.value || $origin_title);
    });
    summary.bind("change", function(event, ui) {
        return pre_summary.text(this.value || $origin_summary);
    });
    return summary.bind("keyup", function(event, ui) {
        return pre_summary.text(this.value || $origin_summary);
    });
};

$(function() {
  return preview_wx_setting(".vMSHead span.title:not('.material_list')", ".vMSFoot p");
});
