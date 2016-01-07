$(function(){
    $(".mod-tools a").mouseenter(function(){
        var self=$(this);
        self.addClass("active");
        self.animate({
            "width":"100px"
        });
    });
    $(".mod-tools a").mouseleave(function(){
        var self=$(this);
        self.removeClass("active");
        self.animate({
            "width":"0"
        });
    });

    $(".mod-list a").mouseenter(function(){
        var self=$(this);
        self.addClass("active");
        self.animate({
            "width":"200px"
        });
    });
    $(".mod-list a").mouseleave(function(){
        var self=$(this);
        self.removeClass("active");
        self.animate({
            "width":"60px"
        });
    });
    $("#tools").affix({
        offset: {
            top: 200,
            bottom: 300
        }
    });
    $(".case-hover").click(function(){
        showModal("modalCase");
    });
    $(".modal-close").click(function(){
        var id=$(this).parents(".modal").attr("id");
        hideModal(id);
    });
});
function showModal(id){
    $("body").append('<div class="modal-backdrop fade active"></div>');
    $("#"+id).addClass("active").show();
}
function hideModal(id){
    $("#"+id).removeClass("active").hide();
    $(".modal-backdrop").remove();
}
