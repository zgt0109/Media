//= require jquery
//= require jquery_ujs
//= require mobile/site01

getImgUrl = function(input,r,idx,fileInfo,fname){
    var token= $(input).attr('data-token') || window.qiniu_token;
    var bucket= $(input).attr('data-bucket') || window.qiniu_bucket;
    var Qiniu_UploadUrl = "http://up.qiniu.com";
    var Qiniu_upload = function(f, token) {
        var xhr = new XMLHttpRequest();
        xhr.open('POST', Qiniu_UploadUrl, true);
        var formData, startDate;
        formData = new FormData();
        formData.append('token', token);
        formData.append('file', f);
        var taking;
        xhr.upload.addEventListener("progress", function(evt) {
            if (evt.lengthComputable) {
                var nowDate = new Date().getTime();
                taking = nowDate - startDate;
                var x = (evt.loaded) / 1024;
                var y = taking / 1000;
                var uploadSpeed = (x / y);
                var formatSpeed;
                if (uploadSpeed > 1024) {
                    formatSpeed = (uploadSpeed / 1024).toFixed(2) + "Mb\/s";
                } else {
                    formatSpeed = uploadSpeed.toFixed(2) + "Kb\/s";
                }
                var percentComplete = Math.round(evt.loaded * 100 / evt.total);
                $(".progress-text").text(percentComplete+"%");
                $(".progress-bar").css("width",percentComplete +"%");
                if(percentComplete == 100){
                    setTimeout(function(){
                        $(".progress-pop").fadeOut(function(){
                            $(this).remove();
                        })
                    },500);
                }
            }else{
                // console.log("ff");
            }
        }, false);
        xhr.onreadystatechange = function(response) {
            if (xhr.readyState == 4 && xhr.status == 200 && xhr.responseText != "") {
                var blkRet = JSON.parse(xhr.responseText);
                var imgUrl='http://'+bucket+'.winwemedia.com/'+blkRet.key;
                // 判断是否需要执行回调函数
                if ($(input).attr("data-callback") != undefined) {
                    eval($(input).attr("data-callback") + "('" + blkRet.key + "', '" + imgUrl + "')")
                }
            } else if (xhr.status != 200 && xhr.responseText) {

            }
        };
        startDate = new Date().getTime();
        xhr.send(formData);
    };
    if (r.length > 0 && token != "") {
        Qiniu_upload(r[idx], token);
    } else {

    }
};

$(function () {
    //上传图片js
    $('body').delegate("input[type=file]", "change", function(){
        var input= this;
        if (input.type === 'file' && input.files && input.files.length > 0) {
            $.each(input.files, function (idx, fileInfo) {
                if (/^image\//.test(fileInfo.type)) {
                    getImgUrl(input,input.files,idx,fileInfo,fileInfo.name);
                    var html ='<div class="progress-pop"><div class="progress-box"><div class="progress-bar"></div><div class="progress-text">0%</div></div></div>';
                    $("body").append(html);
                }
            });
        }
    });

});