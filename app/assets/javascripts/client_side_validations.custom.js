window.ClientSideValidations.callbacks.form.pass = function(form, eventData) {
    $(".form-submit").attr('disabled', true);
    $("img#loading").removeClass("hide");
}

window.ClientSideValidations.callbacks.form.fail = function(form, eventData) {
    form.find('label.error-message:first').prev().focus();
}

var addErrorMessage = function(element, message) {
    element.next('label.error-message').remove();
    element.after('<label class="error-message" for="' + element.attr('id') + '">' + message + '<i></i><em></em></label>');

    var elementM = element.siblings("label.error-message"),
        $left = element.position().left,
        $top = parseInt(element.position().top) - 33;
    elementM.css({
        "left": $left,
        "top": $top
    });
    setTimeout(function() {
        element.on({
            "focus": function() {
                elementM.remove();
            },
            "keypress": function() {
                elementM.remove();
            }
        });
    }, 100);
}

var removeErrorMessage = function(element) {
    element.next('label.error-message').remove();
}

var reDisplayError = function(element) {
    $errorEl = element.next('.error-message');
    if ($errorEl.length > 0) {
        errorMsg = $errorEl.text();
        $errorEl.remove();
        addErrorMessage(element, errorMsg);
    }
}

window.ClientSideValidations.formBuilders = {
    'ActionView::Helpers::FormBuilder': {
        add: function(element, settings, message) {
            addErrorMessage(element, message);
            return element.next("label.error-message");
        },
        remove: function(element, settings) {
            element.next('label.error-message').remove();
        }
    }
};