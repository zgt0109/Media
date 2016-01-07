$(function () {

    //点击下拉
    $(document).on("click", ".select_tab .selectli", function () {
        if ($(this).hasClass("on")) {
            var ind = $(this).index();
            $("body").removeClass("noscroll")
            $(this).removeClass("on");
            $("html,body").removeClass("noscroll");
            $(".select_list").eq(ind).slideUp(0);
            $(this).find(".fa-caret-down").removeClass("fa-caret-up");
            $(".bgshadow").hide();
        }
        else {
            var ind = $(this).index();

            $("html,body ").addClass("noscroll")
            $(".bgshadow").show();
            $(".fa-caret-down").removeClass("fa-caret-up")
            $(this).find(".fa-caret-down").addClass("fa-caret-up")
            $(".selectli").removeClass("on")
            $(this).addClass("on");

            $(".select_list").slideUp(0);
            $(".select_list").eq(ind).slideDown();

        }
    })
    //关闭选项 背景
    $("body").on("click",".select_right a,.shaixuan a",function(){
        $("html,body").removeClass("noscroll");
        $(".select_list").slideUp(0);
        $(".selectli").removeClass("on");
        $(".fa-caret-down").removeClass("fa-caret-up");
        $(".bgshadow").hide();
    })
    //点击背景 关闭选项 背景
    $(".bgshadow").click(function () {

        $("html,body").removeClass("noscroll");
        $(".select_list").slideUp(0);
        $(".selectli").removeClass("on");
        $(".fa-caret-down").removeClass("fa-caret-up");
        $(".bgshadow").hide();
    })


    $(document).on("click", ".select_left li", function () {
        var ind2 = $(this).index();
        $(".select_left li").removeClass("on");
        $(this).addClass("on");
        $(this).parents(".select_left").siblings(".select_right").find("ul").hide().eq(ind2).show()


    })

    //点击评论
    $(document).on("click", ".comment_btn", function () {
        $(this).html("发布评论");

        $(".comment_cont").show();
    })





})
