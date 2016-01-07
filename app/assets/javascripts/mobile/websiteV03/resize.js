! function(win) {
  function setFontSize() {
    var a = element.getBoundingClientRect().width;
    a / v > 540 && (a = 540 * v), win.rem = a / 16, element.style.fontSize = win.rem + "px"
  }
  var v, u, t, doc = win.document,
    element = doc.documentElement,
    viewport = doc.querySelector('meta[name="viewport"]'),
    flexible = doc.querySelector('meta[name="flexible"]');
  if (viewport) {
    // console.warn("将根据已有的meta标签来设置缩放比例");
    var o = viewport.getAttribute("content").match(/initial\-scale=(["']?)([\d\.]+)\1?/);
    o && (u = parseFloat(o[2]), v = parseInt(1 / u))
  } else {
    if (flexible) {
      var o = flexible.getAttribute("content").match(/initial\-dpr=(["']?)([\d\.]+)\1?/);
      o && (v = parseFloat(o[2]), u = parseFloat((1 / v).toFixed(2)))
    }
  }
  if (!v && !u) {
    var n = (win.navigator.appVersion.match(/android/gi), win.navigator.appVersion.match(/iphone/gi)),
      v = win.devicePixelRatio;
    v = n ? v >= 3 ? 3 : v >= 2 ? 2 : 1 : 1, u = 1 / v
  }
  if (element.setAttribute("data-dpr", v), !viewport) {
    if (viewport = doc.createElement("meta"), viewport.setAttribute("name", "viewport"), viewport.setAttribute("content", "initial-scale=" + u + ", maximum-scale=" + u + ", minimum-scale=" + u + ", user-scalable=no"), element.firstElementChild) {
      r.firstElementChild.appendChild(viewport)
    } else {
      var m = doc.createElement("div");
      m.appendChild(viewport), doc.write(m.innerHTML)
    }
  }
  win.dpr = v, win.addEventListener("resize", function() {
    clearTimeout(t), t = setTimeout(setFontSize, 300)
  }, !1), win.addEventListener("pageshow", function(b) {
    b.persisted && (clearTimeout(t), t = setTimeout(setFontSize, 300))
  }, !1), "complete" === doc.readyState ? doc.body.style.fontSize = 12 * v + "px" : doc.addEventListener("DOMContentLoaded", function() {
    doc.body.style.fontSize = 12 * v + "px"
  }, !1), setFontSize()
}(window);