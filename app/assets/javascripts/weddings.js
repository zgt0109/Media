function upload_image(file_input_id, form_id) {
  var upload_file = function() {
    var image_regex = /(\.jpg)|(\.jpeg)|(\.png)|(\.gif)|(\.bmp)/i;
    var filename    = $('#' + file_input_id).val();
    if ( image_regex.test(filename)) {
      $('#' + form_id).submit();
    } else {
      showTip('warning','文件格式不正确')
    };
  }

  var upload_input = $('#' + file_input_id);
  if(navigator.userAgent.match(/msie/i)) {
    upload_input.click(function(event) {
      setTimeout(function() {
        if(upload_input.val().length > 0) {
          upload_file();
        }
      }, 0);
    });
  } else {
    upload_input.change(upload_file);
  }
}

$(function() {
  /* weddings */
  $('#wedding_province_id').change(function() {
    var url = '/weddings/cities?province_id=' + this.value;
    $.getScript(url)
  });


  /* wedding seats status */
  var plugin_page_toggle = function() {
    $(".plugin-show").toggle();
    $(".page").toggle();
  };
  $("#wedding .btn-pluin").unbind('click').click(function(){
    _this = $(this)
    $.post('/weddings/set_seats_status', function() {
      _this.toggleClass("pluin-close").toggleClass("pluin-open");
      plugin_page_toggle();
    });
  });
  if($('.pluin-ft .btn-pluin').hasClass('pluin-close')) {
    plugin_page_toggle();
  };

  var seat_form         = $('#new_wedding_seat');
  // dynamic change number of guest_name inputs
  var set_guest_inputs = function(n) {
    var guest_name_inputs = seat_form.find('p.guest_name');
    var input_num  = n - 1;
    var added_num  = guest_name_inputs.length;
    var needed_num = input_num - added_num
    if (needed_num > 0) {
      var html = '<p class="guest_name"><input type="text" class="input-text guest-input" name="guest_names[]"/></p>';
      for (var i = 0; i < needed_num; i++) {
        seat_form.append(html);
      };
    } else if (needed_num < 0) {
      for (var i = -1; i >= needed_num; i--) {
        guest_name_inputs.eq(i).remove();
      };
    }
  }

  var clear_seat_form = function() {
    $('#wedding_seat_name').val('');
    $('#wedding_seat_seats_count').val(1);
    seat_form.find('input.guest-input').val('');
    seat_form.attr('action', seat_form.data('original-path'));
    $('#seat_method').val('post');
  }

  $('.seat-add-btn').click(function() {
    clear_seat_form();
    set_guest_inputs(1);
  });


  $('#wedding_seat_seats_count').on('blur', function() {
    var n = parseInt(this.value);
    if (!$.isNumeric(n) || n < 1 || n > 10) {
      this.value = n = 1;
    };
    set_guest_inputs(n);
  });

  $('#seat_save_link').unbind('click').click(function() {
    seat_form.submit();
    // showTip('warning',seat_form.find('p.guest_name').length)
  });

  $('.seat-edit-btn').click(function() {
    var seat_id = $(this).data('id');
    var path    = $(this).data('path');
    $.getJSON(path, function(data) {
      $('#seat_method').val('put');
      $('#wedding_seat_name').val(data.name);
      $('#wedding_seat_seats_count').val(data.seats_count);
      seat_form.attr('action', path);
      set_guest_inputs(data.seats_count);
      var guest_inputs = seat_form.find('input.guest-input');
      for(var i = 0; i < data.guests.length; i++) {
        guest_inputs.eq(i).val(data.guests[i]);
      }
    });
  });



  /* wedding pictures */
  if ($('#wedding_picture_upload_input').length > 0) {
    upload_image('wedding_picture_upload_input', 'new_wedding_picture')
  };

  var video_regex = /\.(rm)|(rmvb)|(wmv)|(avi)|(mpg)|(mpeg)|(mp4)$/i
  var video_upload_input = $('#video_upload_input');
  if(navigator.userAgent.match(/msie/i)) {
    video_upload_input.click(function() {
      setTimeout(function() {
        var value = video_upload_input.val();
        if(value.length > 0 && !video_regex.test(value)) {
          showTip('warning',"视频文件格式不正确");
          video_upload_input.replaceWith(video_upload_input = video_upload_input.clone(true));
        }
      }, 0);
    });
  } else {
    video_upload_input.change(function() {
      if(!video_regex.test(video_upload_input.val())) {
        showTip('warning',"视频文件格式不正确");
        video_upload_input.val('');
      }
    });
  }

})