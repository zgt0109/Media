(function( $ ) {

  // Shorthand to make it a little easier to call public laravel functions from within laravel.js
  var laravel;

  $.laravel = laravel = {
    // Link elements bound by jquery-ujs
    linkClickSelector: 'a[data-method]',

    // Default way to get an element's href. May be overridden at $.laravel.href.
    href: function(element) {
      return element.attr('href');
    },

    // Handles "data-method" on links such as:
    // <a href="/users/5" data-method="delete" rel="nofollow" data-confirm="Are you sure?">Delete</a>
    handleMethod: function(link) {
      var href = laravel.href(link),
      method = link.data('method'),
      target = link.attr('target'),
      csrf_token = $('meta[name=csrf-token]').attr('content'),
      csrf_param = $('meta[name=csrf-param]').attr('content'),
      form = $('<form method="post" action="' + href + '"></form>'),
      metadata_input = '<input name="_method" value="' + method + '" type="hidden" />';

      if (csrf_param !== undefined && csrf_token !== undefined) {
        metadata_input += '<input name="' + csrf_param + '" value="' + csrf_token + '" type="hidden" />';
      }

      if (target) { form.attr('target', target); }

      form.hide().append(metadata_input).appendTo('body');
      //form.submit();
    }
  }

  $(document).on('click.laravel', laravel.linkClickSelector,  function(e) {
    var link = $(this), method = link.data('method');

    if (link.data('method')) {
      laravel.handleMethod(link);
      return false;
    }
  });

})( jQuery );