;(function(){
	$.fn.qiniuUploadImg = function(options){
		var defaults = {
				multiple: false,
				token: '',
				bucket: '',
				fnUploadAllStart: function(fileInput, fileCount, files){},
				fnUploadInit: function(fileInput, fileCount, index, file){}, // 每个图片上传前的一些初始化操作
				fnUploadProgress: function(fileInput, fileCount, index, percent){},  // 每个图片上传过程中的操作
				fnUploadComplete: function(fileInput, fileCount, index, src){}  // 每个图片上传完毕后的操作
			},
			o = $.extend({}, defaults, options),
			Qiniu_UploadUrl = "http://up.qiniu.com";

		this.each(function(i){
			var self = $(this);

			self.prop('multiple', o.multiple);

			self.change(function(){

				var fileList = this.files;
				var fileCount = fileList.length;

				$.isFunction(o.fnUploadAllStart) && o.fnUploadAllStart(self, fileCount, fileList);

				$.each(fileList, function(j, file){
					var xhr = new XMLHttpRequest();
					var formData = new FormData();

					xhr.open('POST', Qiniu_UploadUrl, true);
					formData.append('token', o.token);
					formData.append('file', file);

					$.isFunction(o.fnUploadInit) && o.fnUploadInit(self, fileCount, j, file);

					xhr.onreadystatechange = function(response) {
						if (xhr.readyState == 4 && xhr.status == 200 && xhr.responseText != "") {
							var blkRet = JSON.parse(xhr.responseText);
							var imgUrl = 'http://' + o.bucket + '.winwemedia.com/' + blkRet.key;

							$.isFunction(o.fnUploadComplete) && o.fnUploadComplete(self, fileCount, j, imgUrl);
						}
					};
					xhr.upload.addEventListener("progress", function(e) {
						if(e.lengthComputable){
							var percent = Math.round(e.loaded * 100 / e.total);

							$.isFunction(o.fnUploadProgress) && o.fnUploadProgress(self, fileCount, j, percent, e);
						}
					}, false);
					xhr.send(formData);
				});

			});

		});
	};
})();