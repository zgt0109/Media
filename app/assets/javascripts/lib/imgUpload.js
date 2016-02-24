;(function($,win,doc){
    "use strict";
    $.cieldonfileupload=function(el, options){
        var self=this,
            o,
            t;
        self.el=el;
        self.$el=$(el);
        self.$el.data("CieldonFileuoload",self);
        self.input=self.$el.find("input[type=file]");
        self.init=function(){
            self.options = o = $.extend({}, $.cieldonfileupload.defaults, options);
            self.width=self.$el.attr("data-width") || o.width;
            self.height=self.$el.attr("data-height") || o.height;
            self.type=self.$el.attr("data-type") || o.type;
            self.target=self.$el.attr("data-div");
            self.album_id=self.$el.attr("data-album-id");
            self.wx_wall_id=self.$el.attr("data-wx-wall-id");
            self.college_id=self.$el.attr("data-college-id");
            self.shop_branch_id=self.$el.attr("data-shop-branch-id");
            self.attr=self.$el.attr("data-attr");
            self.img=self.$el.attr("data-img");
            self.img_ids=self.$el.attr("data-img-ids");
            self.name=self.$el.attr("data-name");
            self.key=self.$el.data("key") || "";

            self.fa=self.$el.attr("data-fa");
            self.id=self.$el.attr("data-id");
            self.em=self.$el.attr("data-em");
            self.imgs_type = self.$el.attr("data-imgs-type");
            self.location = self.$el.attr("data-location");
            self.client = self.$el.attr("data-client");
            self.create_api_url  = self.$el.attr("data-create-api-url");
            self.destroy_api_url  = self.$el.attr("data-destroy-api-url");
            self.tag_api_url  = self.$el.attr("data-tag-api-url");
            var attrStr='';
            if(self.attr){
                self.attr=self.attr.split(",");
                $.each(self.attr,function(i){
                    var list=self.attr[i].split(":");
                    list.splice(1,0,"=");
                    $.each(list,function(j){
                        if(j==2){
                            attrStr+='"'+list[j]+'" ';
                        }else{
                            attrStr+=list[j];
                        }
                    });
                });
            }
            function getImglist(){
                var imgs=[], img_ids= [], img_keys = [];
                var img="", $em = "";
                var w=self.width,
                    h=self.height;
                if(self.img&&self.img!=""){
                    imgs=self.img.split(",");
                }
                if(self.img_ids&&self.img_ids!=""){
                    img_ids = self.img_ids.split(",");
                }
                if (self.key&&self.key!=""){
                    img_keys = self.key.split(",");
                }
                if(self.em&&self.em!=""){
                    var ems=self.em.split(",");
                    $em='<em class="file-tag" data-toggle="text" data-text="'+ems[0]+','+ems[1]+'">'+ems[0]+'</em>';
                }
                $.each(imgs,function(i){
                    img+='<div class="file-img" style="width:'+w+'px; height: '+h+'px;"><div class="file-btn"><a style="background-image: url('+imgs[i]+')" img-id="'+img_ids[i]+'" data-key="' + img_keys[i] +'"></a></div><i class="fa fa-times file-del"></i>'+$em+'</div>';
                });
                return img;
            }

            function max_file_load(name){
                $(".cieldon-file .file-img").eq(0).click(function(){
                    if($("input[name='"+name+"']").val().split(',').length >= 5){
                        alert("最多只能上传5张图片");
                        return false;
                    }
                });
            }

            self.$el.addClass("cieldon-file-"+self.type);
            switch (self.type){
                case "0":
                    if(self.fa&&self.fa!=""){
                        self.$el.html('<div class="file-img" style="width: '+self.width+'px; height: '+self.height+'px;"><div class="file-btn"><a style="width: '+self.width+'px; height: '+self.height+'px; background:#1b6aaa; color:#fff; font-size:30px;"><p><i class="'+self.fa+'"></i></p></a><input type="file" value="上传图片" data-token="'+ o.token+'" data-bucket="'+o.bucket+'" accept＝".jpg, .jpeg, .png" '+attrStr+'/><input type="hidden" name="'+self.name+'" value="'+self.key+'"/></div></div>');
                    }else{
                        self.$el.html('<div class="file-img" style="width: '+self.width+'px; height: '+self.height+'px;"><div class="file-btn"><a style="width: '+self.width+'px; height: '+self.height+'px; background-image: url('+self.img+')"><p><i class="fa fa-plus"></i><small style="background: rgba(0, 0, 0, 0.5); line-height: 24px;">上传图片</small></p></a><input type="file" value="上传图片" data-token="'+ o.token+'" data-bucket="'+o.bucket+'" accept＝".jpg, .jpeg, .png" '+attrStr+'/><input type="hidden" name="'+self.name+'" value="'+self.key+'"/></div></div>');
                    }
                    break;
                case "1":
                    self.$el.html('<div class="file-btn"><a class="btn btn-primary btn-sm">上传图片</a><input type="file" value="上传图片" data-div="'+self.target+'" data-token="'+ o.token+'" data-bucket="'+o.bucket+'" data-width="'+self.width+'" data-height="'+self.height+'" accept＝".jpg, .jpeg, .png" '+attrStr+'/><input type="hidden" name="'+self.name+'" value="'+self.key+'"/></div>');
                    if(self.img){
                        $(self.target).css({"background-image":"url("+self.img+")","background-size": "cover","background-repeat": "no-repeat","width":self.width,height:self.height});
                    }
                    break;
                case "2":
                    var img=getImglist();
                    self.$el.html('<div class="file-img" style="width: '+self.width+'px; height: '+self.height+'px;"><div class="file-btn"><a><p><i class="fa fa-plus"></i><small>上传图片</small></p></a><input type="file" value="上传图片" multiple data-token="'+ o.token+'" data-bucket="'+o.bucket+'" accept＝".jpg, .jpeg, .png" '+attrStr+'/><input type="hidden" name="'+self.name+'" value="'+self.key+'"/></div></div>'+img);
                    break;
                case "3":
                    var img=getImglist();
                    self.$el.html('<div class="file-btn"><a class="btn btn-primary btn-sm">上传图片</a><input type="file" value="上传图片" multiple data-div="'+self.target+'" data-token="'+ o.token+'" data-bucket="'+o.bucket+'" data-width="'+self.width+'" data-height="'+self.height+'" accept＝".jpg, .jpeg, .png" '+attrStr+'/><input type="hidden" name="'+self.name+'" value="'+self.key+'"/></div><div class="file-list">'+img+'</div>');
                    break;
                case "4":
                    self.$el.html('<div class="file-btn"><a class="btn btn-primary btn-sm">上传语音</a><input type="file" value="上传语音" data-token="'+ o.token+'" data-bucket="'+o.bucket+'" '+attrStr+' data-name="'+self.name+'" id="'+self.id+'" accept=".mp3,.aif,.wav,.rm,.wmv"/></div>');
                    break;
                case "5":
                    // 微相册多图上传
                    self.$el.html('<div class="file-img" style="width: '+self.width+'px; height: '+self.height+'px;"><div class="file-btn"><a style="width: '+self.width+'px; height: '+self.height+'px; background-image: url('+self.img+')"><p><i class="fa fa-plus"></i><small>上传图片</small></p></a><input multiple="multiple" album_id="'+self.album_id+'" type="file" value="上传图片" data-token="'+ o.token+'" data-bucket="'+o.bucket+'" accept＝".jpg, .jpeg, .png" '+attrStr+'/><input type="hidden" name="'+self.name+'" value="'+self.key+'"/></div></div>');
                    break;
                case "6":
                    var img=getImglist();
                    self.$el.html('<div class="file-img" style="width: '+self.width+'px; height: '+self.height+'px;"><div class="file-btn"><a><p><i class="fa fa-plus"></i><small>上传图片</small></p></a><input type="file" value="上传图片" multiple data-token="'+ o.token+'" data-bucket="'+o.bucket+'" accept＝".jpg, .jpeg, .png" '+attrStr+'/><input type="hidden" name="'+self.name+'" value="'+self.key+'"/></div></div>'+img);
                    break;
                case '7':
                    self.$el.html('<div class="file-btn"><a class="btn btn-primary btn-sm">上传图片</a><input type="file" value="上传图片" data-div="'+self.target+'" data-token="'+ o.token+'" data-bucket="'+o.bucket+'" data-width="'+self.width+'" data-height="'+self.height+'" accept＝".jpg, .jpeg, .png" '+attrStr+'/><input type="hidden" name="'+self.name+'" value="'+self.key+'"/></div>');
                    $('#header_bg').attr('src', self.img);
                    break;
                case "8":
                    self.$el.html('<div class="file-btn"><a class="btn btn-primary btn-sm">上传LOGO</a><input type="file" value="上传LOGO" data-div="'+self.target+'" data-token="'+ o.token+'" data-bucket="'+o.bucket+'" data-width="'+self.width+'" data-height="'+self.height+'" accept＝".jpg, .jpeg, .png" '+attrStr+'/><input type="hidden" name="'+self.name+'" value="'+self.key+'"/></div>');
                    if(self.img){
                        $(self.target).css({"background-image":"url("+self.img+")","background-size": "100% 100%","background-repeat": "no-repeat","width":self.width,height:self.height});
                    }
                    break;
                case "9"://微团购
                    var img=getImglist();
                    self.$el.html('<div class="file-img" style="width: '+self.width+'px; height: '+self.height+'px;"><div class="file-btn"><a><p><i class="fa fa-plus"></i><small>上传图片</small></p></a><input type="file" value="上传图片" multiple data-token="'+ o.token+'" data-bucket="'+o.bucket+'" accept＝".jpg, .jpeg, .png" '+attrStr+'/><input type="hidden" name="'+self.name+'" value="'+self.key+'"/></div></div>'+img);
                    if(self.$el.attr("data-onloadback") != undefined){
                        max_file_load(self.$el.attr("data-name"));
                    }
                    break;
                default :
                    break;
            };
            self.img_key_input_func = function () {
              if (typeof(self.name) == "undefined") {
                return self.input.next()
              } else {
                return $("input[name='"+self.name+"']")
              }
            };
            self.img_key_input = self.img_key_input_func();
            self.$el.delegate("input[type=file]", "change",function(){
                //self.$el.on("change",self.input,function(){
                //var input= $(this).find("input[type=file]")[0];
                var input= this
                if (input.type === 'file' && input.files && input.files.length > 0) {
                    if ($(input).attr("album_id") == "-1"){
                        showTip("warning","请先保存相册，再上传照片！");
                        return false;
                    }else{
                        $.each(input.files, function (idx, fileInfo) {
                            if (/^image\//.test(fileInfo.type)) {
                                self.getImgUrl(input,input.files,idx,self.type,fileInfo,fileInfo.name);
                            }else if(/^audio\//.test(fileInfo.type)){
                                //self.getImgUrl(input,input.files,idx,self.type,fileInfo,fileInfo.name);
                            }else {
                                options.fileUploadError("unsupported-file-type", fileInfo.type);
                            }
                            var html ='<div class="progress-pop"><div class="progress-box"><div class="progress-bar"></div><div class="progress-text">0%</div></div></div>';
                            $("body").append(html);
                        });
                    }
                }
            });
            if(self.destroy_api_url && self.destroy_api_url.length>0){
                self.$el.on("click",".file-del",function(){
                    var parent_el = $(this).parents(".file-img");
                    var id = parent_el.find("a").attr("img-id");
                    if(id>0){
                        parent_el.remove();
                        $.post(self.destroy_api_url+"/"+id, {"_method": "delete"}, function(result){ });
                    };
                });
            };
            if(self.tag_api_url && self.tag_api_url.length>0){
                self.$el.on("click",".file-tag",function(){
                    var parent_el = $(this).parents(".file-img");
                    var id = parent_el.find("a").attr("img-id");
                    if(id>0){
                        $.post(self.tag_api_url.replace("@",id), {}, function(result){ });
                    };
                });
            };
            if(self.type != 6){
                self.$el.on("click",".file-del",function(){
                var parent_el = $(this).parents(".file-img");
                var remove_key = parent_el.find("a").data().key || "";

                if (remove_key.length > 0) { self.remove_img(remove_key)};
                  $(this).parents(".file-img").remove();
                });
            }
        };
        self.init();
        self.readFileIntoDataUrl=function(fileInfo){
            var loader = $.Deferred(),
                fReader = new FileReader();
            fReader.onload = function (e) {
                loader.resolve(e.target.result);
            };
            fReader.onerror = loader.reject;
            fReader.onprogress = loader.notify;
            fReader.readAsDataURL(fileInfo);
            return loader.promise();
        };
        self.getImgUrl=function(input,r,idx,type,fileInfo,fname){
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
                        if (self.$el.attr("data-callback") != undefined) {
                           eval(self.$el.attr("data-callback") + "('" + blkRet.key + "', '" + imgUrl + "')")
                           // var callback = self.$el.attr("data-callback");
                           // if(callback)window[callback](imgUrl);
                        }
                        self.renderImg(input,imgUrl,type,fname, blkRet.key);
                    } else if (xhr.status != 200 && xhr.responseText) {

                    }
                };
                startDate = new Date().getTime();
                xhr.send(formData);
            };
            if (r.length > 0 && token != "") {
                Qiniu_upload(r[idx], token);
            } else {
                $.when(self.readFileIntoDataUrl(fileInfo)).done(function (dataUrl) {
                    self.renderImg(input,dataUrl,type,fname, '');
                }).fail(function (e) {
                        // console.log("出错了");
                    });
            }

        };
        self.insert_img= function(key) {
            var img_key = self.img_key_input.val() || "";
            var img_arr = img_key.split(",")
            img_arr.push(key);
            img_arr.map(function(x,i) { if ( x == '') {img_arr.splice(i,1) }})

            img_key = img_arr.join(",")
            self.img_key_input.val(img_key)
        };
        self.remove_img= function(key) {
            var img_key = self.img_key_input.val() || "";
            var img_arr = img_key.split(",");

            var index = img_arr.indexOf(key);

            if (index > -1) {
                img_arr.splice(index, 1);

                $.map(function(x,i) { if ( x == '') {img_arr.splice(i,1) }})
                img_key = img_arr.join(",")
                self.img_key_input.val(img_key)
            }

        };
        self.renderImg=function(input,img,type,fname, key){
            $(input).attr("value",img);
            $(input).attr("data-fname",fname);
            switch (type){
                case "0":
                    var a=$(input).prev();
                    a.css({"background-image":"url("+img+")", 'background-color': '', 'font-size': '', 'background-position': '', 'background-repeat': 'no-repeat', "background-size": "100% 100%"});
                    self.img_key_input.val(key);
                    if($(input).next()){$(input).next().val(key);}
                    if($(self)[0].imgs_type == "print"){
                    var attr = $(self)[0].location;
                        var key = img;
                        var id = $(self)[0].client;
                        $.ajax({
                            type: "POST",
                            url: "/prints/"+id+"/update_pics",
                            data: { att: attr, key: key },
                            success: function(){
                                //alert('upload success');
                            }
                        });

                    }
                    break;
                case "1":
                    var w=$(input).attr("data-width") || "100%",
                        h=$(input).attr("data-height") || "100%";
                    self.img_key_input.val(key);
                    $(self.target).css({"background-image":"url("+img+")","background-size": "cover","background-repeat": "no-repeat","width":w,height:h});
                    break;
                case "2":
                    self.insert_img(key);
                    var fileImg=$(input).parents(".file-img"),
                        w=fileImg.innerWidth(),
                        h=fileImg.innerHeight(),
                        html='<div class="file-img" style="width:'+w+'px; height: '+h+'px;"><div class="file-btn"><a style="background-image: url('+img+')" data-key="'+ key +'"></a><input type="file" value="上传图片"></div><i class="fa fa-times file-del"></i></div>';
                    fileImg.after(html);
                    break;
                case "3":
                    self.insert_img(key);
                    var fileList=$(input).parents(".file-btn").next(".file-list"),
                        w=$(input).attr("data-width"),
                        h=$(input).attr("data-height"),
                        html='<div class="file-img" style="width:'+w+'px; height: '+h+'px;"><div class="file-btn"><a style="background-image: url('+img+')"></a><input type="file" value="上传图片"></div><i class="fa fa-times file-del"></i></div>';
                    fileList.prepend(html);
                    break;
                case "9":
                    self.insert_img(key);
                    var fileImg=$(input).parents(".file-img"),
                        w=fileImg.innerWidth(),
                        h=fileImg.innerHeight(),
                        html='<div class="file-img" style="width:'+w+'px; height: '+h+'px;"><div class="file-btn"><a style="background-image: url('+img+')" data-key="'+ key +'"></a><input type="file" value="上传图片"></div><i class="fa fa-times file-del"></i></div>';
                    fileImg.after(html);
                    break;
                case "5":
                    // 微相册多图上传
                    var album_id = parseInt(self.album_id);
                    if (!isNaN(album_id)){
                        $.post("/album_photos/save_qiniu_keys", {name: fname, pic_key: key, album_id: album_id}, function(result){
                            $(".vwebsitePicture li.active").after(result);
                        });
                    }
                    // 微信墙多图上传
                    var wx_wall_id = parseInt(self.wx_wall_id);
                    if (!isNaN(wx_wall_id)){
                        $.post("/wx_walls/save_qiniu_keys", {name: fname, pic_key: key, wx_wall_id: wx_wall_id}, function(result){
                            $(".vwebsitePicture li.active").after(result);
                        });
                    }
                    // 微教育多图上传
                    var college_id = parseInt(self.college_id);
                    if (!isNaN(college_id)){
                        $.post("/colleges/"+ college_id +"/college_photos", {college_photo: {name: fname, pic_key: key}}, function(result){
                            $(".vwebsitePicture li.active").after(result);
                        });
                    }
                    // 微门店多图上传
                    var shop_branch_id = parseInt(self.shop_branch_id);
                    if(!isNaN(shop_branch_id) && $('.photo-li').length >= 10){
                        showTip('warning', '最多上传10张图片');
                        return false;
                    }else if (!isNaN(shop_branch_id)){
                        $.post("/micro_shop_branches/"+ shop_branch_id +"/create_pic", {pic_key: key}, function(result){
                            $(".vwebsitePicture li.active").after(result);
                        });
                    }
                    break;
                case "6":
                    self.insert_img(key);
                    var fileImg=$(input).parents(".file-img"),
                        w=fileImg.innerWidth(),
                        h=fileImg.innerHeight();
                    var $em="";
                    if(self.em&&self.em!=""){
                        var ems=self.em.split(",");
                        $em='<em class="file-tag" data-toggle="text" data-text="'+ems[0]+','+ems[1]+'">'+ems[0]+'</em>';
                    }
                    var html='<div class="file-img" style="width:'+w+'px; height: '+h+'px;"><div class="file-btn"><a style="background-image: url('+img+')"></a></div><i class="fa fa-times file-del"></i>'+$em+'</div>';
                    if( self.create_api_url && self.create_api_url.length>0){
                        $.post(self.create_api_url, {file_name: fname, pic_key: key}, function(result){
                            var id = result.id;
                            var html='<div class="file-img" style="width:'+w+'px; height: '+h+'px;"><div class="file-btn"><a img-id='+id+' style="background-image: url('+img+')"></a></div><i class="fa fa-times file-del"></i>'+$em+'</div>';
                            fileImg.after(html);
                        });
                    }else if(self.imgs_type == "hotel_pictures"){
                        // 微酒店图片上传
                        var hotel_id = $(input).parents(".cieldon-file").data('hotel-id'),
                            hotel_branch_id = $(input).parents(".cieldon-file").data('hotel-branch-id'),
                            params = {hotel_picture: {hotel_id: hotel_id,  hotel_branch_id: hotel_branch_id,  qiniu_path_key: key}}
                        $.post("/hotel_pictures", params, function(result){
                            if($('.file-img').length >= 21){
                                showTip('warning', '最多上传20张图片');
                                return false;
                            }else{
                                if(result['type'] == 'success'){
                                    $.each($('.file-img'), function(){
                                        if($(this).find('em').text() == '取消封面'){
                                            fileImg = $(this);
                                        }
                                    });
                                    fileImg.after(html);
                                    fileImg.next().find('.file-btn a').attr('img-id', result['id']);
                                    $('.pictures-operate').append('<a href="/hotel_pictures/'+result['id']+'/cover" class="cover" data-confirm="确认将此图片设为封面吗？" data-id="'+result['id']+'" data-method="post">设为封面</a>');
                                    $('.pictures-operate').append('<a href="/hotel_pictures/'+result['id']+'/discover" class="discover" data-confirm="确认取消此封面图片吗？" data-id="'+result['id']+'" data-method="post">取消封面</a>');
                                    $('.pictures-operate').append('<a href="/hotel_pictures/'+result['id']+'" class="remove" data-confirm="确认删除此图片吗？" data-id="'+result['id']+'" data-method="delete">删除</a>');
                                }
                                showTip(result['type'], result['info']);
                            }
                        });
                    }else if(self.imgs_type == "booking_item_pictures"){
                        // 微服务商品图片上传
                        fileImg.after(html);
                        var uuid = Date.now();
                        fileImg.next().append('<input class="destroy" name="booking_item[booking_item_pictures_attributes]['+uuid+'][_destroy]" type="hidden">')
                        fileImg.next().append('<input class="pic_key" name="booking_item[booking_item_pictures_attributes]['+uuid+'][pic_key]" type="hidden" value="'+key+'">')
                    }
                  
                    else if(self.imgs_type == "panoramagram"){
                        // 360全景图片上传
                        if($(".file-del").length >= 6){
                            showTip('warning', '最多上传6张图片');
                            return false;
                        }else{
                            fileImg.after(html);
                            var item = '<input name="panoramagram[items_attributes]['+Date.now()+'][_destroy]" type="hidden" value="0"><input name="panoramagram[items_attributes]['+Date.now()+'][pic_key]" type="hidden" value="'+key+'"><input name="panoramagram[items_attributes]['+Date.now()+'][sort]" type="hidden" value="'+($(".file-del").length)+'">';
                            $('#items').after(item);
                        }
                    }else{
                        fileImg.after(html);
                        // 微汽车车型图片上传
                        var car_type_id=$(input).parents(".cieldon-file").data('car_type_id'),
                        pic_type=$(input).parents(".cieldon-file").data('pic_type');
                        $.post("/car_pictures", {car_type_id: car_type_id, pic_key: key, pic_type: pic_type}, function(result){ });
                    }
                break;
            case '7':
                self.img_key_input.val(key);
                $('#header_bg').attr('src', img);
                // $('#album_top_img_type').val(1);
                break;
            case "8":
                    var w=$(input).attr("data-width") || "100%",
                        h=$(input).attr("data-height") || "100%";
                    self.img_key_input.val(key);
                    $(self.target).css({"background-image":"url("+img+")","background-size": "100% 100%","background-repeat": "no-repeat","width":w,height:h});
                    // 二维码推广logo上传
                    if($("#qrcode_channel_logo").length){
                        $("#qrcode_channel_logo").val(key);
                    }
                    break;
            default :
                break;
            };
            self.img_key_input.trigger('change');
        }
    };
    $.cieldonfileupload.defaults={
        width:"",
        height:"",
        type:"",
        token: window.qiniu_bucket || "",
        bucket: window.qiniu_token || ""
    };
    $.fn.cieldonfileupload=function(options,callback){
        return this.each(function(){
            var cdfileupload = $(this).data('CieldonFileuoload');
            if ((typeof(options)).match('object|undefined')){
                if (!cdfileupload) {
                    (new $.cieldonfileupload(this, options));
                }
            }
        });
    };
})(jQuery, window, document);
