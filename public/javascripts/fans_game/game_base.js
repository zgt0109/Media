if (void 0 == APP_BASE_URL) var APP_BASE_URL = "../game-list.html";
if (void 0 == GAME_LIST_URL) var GAME_LIST_URL = "../game-list.html";
if (void 0 == FOLLOW_URL) var FOLLOW_URL = "../game-list.html";
var BASE_RES_DIR = "../",
    RES_DIR = "",
    APP_DEPLOYMENT = "WEB",
    USE_NATIVE_SOUND = !1,
    USE_NATIVE_SHARE = !1,
    IS_IOS = navigator.userAgent.match(/(iPad|iPhone|iPod)/g) ? !0 : !1,
    IS_ANDROID = -1 < navigator.userAgent.indexOf("Android"),
    IS_NATIVE_ANDROID = false,
    IS_REFFER = !1,
    SHOW_LLAMA = !0,
    SHOW_COPYRIGHT = !1,
    IN_WEIXIN = !1;
0 <= document.URL.indexOf("file://") && (IS_ANDROID || IS_IOS) && (APP_DEPLOYMENT = "APP", USE_NATIVE_SOUND = USE_NATIVE_SHARE = !0, APP_BASE_URL = "../game-list.html");
document.addEventListener("WeixinJSBridgeReady", function() {
    IN_WEIXIN = !0;
    WeixinJSBridge.call("showOptionMenu");
    WeixinJSBridge.call("hideToolbar")
});
var PID = 0,
    USERNAME = "",
    IS_SUB = !1,
    GAME_URL = APP_BASE_URL + "game/" + GID,
    BEST_URL = APP_BASE_URL + "best/" + GID,
    UPLOAD_URL = APP_BASE_URL + "upload/" + GID,
    LB_URL = APP_BASE_URL + "lb/" + GID,
    ACTION_URL = APP_BASE_URL + "actionlog",
    best = -1E4,
    score = 0,
    record_flag = !1,
    logFlag = !1,
    keyStorage = "best:" + GID + ":" + PID;

function initBest() {
    best = gjStorage.get(keyStorage) || -1E4
}

function cacheBest(a) {
    a > best && (best = a, gjStorage.set(keyStorage, best))
}

function onNewScore() {
    return gjQipa.newscore_wxoauth(score)
}

function share() {
    document.getElementById("share").style.display = "block";
}

function showTop(a) {
    IS_TOUCH && a.nativeEvent instanceof MouseEvent || showTop()
}

function showTop() {
    showPopup(LB_URL)
}
$(function() {
    $("#lbFrame").hide();
    $(".closeIframe").click(function() {
        hidePopup()
    })
});

function showPopup(a) {
    window.location.href = "../game-list.html";
    return false;
    var b = document.body.scrollWidth,
        c = document.body.scrollHeight;
    $("#lbFrame").css({
        width: b,
        height: c
    }).attr("src", a).fadeIn();
    $(".closeIframe").show()
}

function hidePopup() {
    $("#lbFrame").fadeOut();
    $(".closeIframe").fadeOut();
    "function" == typeof onPopupClose && onPopupClose()
}

function parseSearchArgs() {
    for (var a = location.search, b = /(\w+)=([^&]*)/g, c, d = {}; c = b.exec(a);) d[c[1]] = c[2];
    return d
}

function sendSearchArgs() {
    "APP" != APP_DEPLOYMENT && "undefined" != typeof GAME_URL && $.getJSON(getLoadGameDataUrl(!0), function(a) {
        _loadGameData(a);
        initBest()
    })
}

function getLoadGameDataUrl(a) {
    var b = location.search;
    0 == b.length && (b = "?");
    var c = b.charAt(b.length - 1);
    "?" != c && "&" != c && (b += "&");
    return GAME_URL + (b + ("callback=" + (a ? "?" : "_loadGameData")))
}

function _loadGameData(a) {
    IS_SUB = a.sub;
    PID = a.pid;
    USERNAME = a.name
}
(function(a, b) {
    a.get = function(a) {
        try {
            a in localStorage && ($.cookie(a, localStorage[a], {
                expires: 60
            }), localStorage.removeItem(a))
        } catch (b) {}
        return $.cookie(a)
    };
    a.set = function(a, b) {
        $.cookie(a, b, {
            expires: 60
        });
        return !0
    }
})(window.gjStorage = window.gjStorage || {});
(function(a, b) {
    a.newscore_wxoauth = function(a) {
        var b = APP_BASE_URL + "wxoauth/newscore/" + GID;
        a > best && (record_flag = !0, cacheBest(a));
        a <= SCORE_LIMIT || (b += "?" + $.param({
            score: a,
            return_url: location.origin + location.pathname
        }), console.log(b), $.getJSON(b + "&callback=?").done(function(a) {
            "wxoauth_needed" == a.error && !0 == window.confirm("\u9700\u8981\u540d\u5b57\u624d\u80fd\u4e0a\u4f20\u9ad8\u5206\uff0c\u8bf7\u6388\u6743\u5fae\u4fe1\u8bfb\u53d6\u60a8\u7684\u540d\u5b57\u548c\u5934\u50cf\u3002") && window.open(b, "_parent")
        }))
    };
    a.onGameInit = function() {};
    a.onGameStarted = function() {};
    a.onGameOver = function() {}
})(window.gjQipa = window.gjQipa || {});