// v 1.1
;(function($){
	$.fn.Ztip = function(options){
		var defaults = {
			tipColor: "#bbb"
		}

		o = $.extend({}, defaults, options);

		return this.each(function(){

	    	var t = $(this),
		    	tipValue = t.data("tip"),
		    	originalColor = t.css("color"),
		    	originalType = t.attr("type") || t.prop("tagName"),
		    	except = o.exceptClass,
		    	isPass = (originalType.toLowerCase() == "password"),
		    	isTextarea = (originalType.toLowerCase() == "textarea");

                // t.attr("placeholder", tipValue);
		    	
		    	if(isPass){
		    		var passClass = t.attr("class");
		    		var passSimu = '<input type="text" class="{class}" />';
		    		var simu = null;
                
		    		// 排除原来password的某些class
		    		if(except){
		    			$.each(except, function(key, val){
		    				passClass = passClass.replace(val, "");
		    			});
		    		}
                
		    		passSimu = passSimu.replace("{class}", passClass);
                
		    		simu = $(passSimu).css({display: "block"});
		    		t.hide().parent().prepend(simu);
                
		    		simu.on("focus.plugin", function(){
		    			if(t.val().replace(/\s*/g,"") == "" || t.val() == tipValue){
		    				t.val("");
		    				t.css({color:originalColor});
                
		    				t.show().trigger("focus.plugin");
		    				simu.hide();
		    			}
		    		});
		    		t.on("blur.plugin", function(){
		    			if(t.val().replace(/\s*/g,"") == "" || t.val() == tipValue){
		    				simu.val(tipValue);
		    				simu.css({color:o.tipColor});
                
		    				t.hide();
		    				simu.show().trigger("blur.plugin");
		    			}
		    		})
                
		    		// 修复浏览器记住密码问题
		    		if(t.val() != "" && t.val() != tipValue){
		    			t.show();
		    			simu.hide();
		    		}else{
		    			t.triggerHandler("blur.plugin");
		    		}
		    	}else{
		    		t.on("blur.plugin", function(){
		    			if(t.val().replace(/\s*/g,"") == "" || t.val() == tipValue){
		    				t.val(tipValue);
		    				t.css({color:o.tipColor});
		    			}
		    		}).on("focus.plugin", function(){
		    			if(t.val().replace(/\s*/g,"") == "" || t.val() == tipValue){
		    				t.val("");
		    				t.css({color:originalColor});
		    			}
		    		}).triggerHandler("blur.plugin");
                
		    		// 修复浏览器记住密码问题
		    		if(t.val() == "" || t.val() == tipValue){
		    			t.triggerHandler("blur.plugin");
		    		}
		    	}
		    	
		});
	};


}(jQuery));