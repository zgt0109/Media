H = 1E3;
var qp_a = W / 4,
    qp_b = H / 4,
    qp_c = 3,
    qp_d = 0,
    qp_e = 0,
    qp_f, qp_g, qp_h, qp_i, qp_j = 15,
    qp_k = 32,
    qp_l = 300,
    qp_m, qp_n = 0,
    qp_o = 0,
    qp_p, qp_q = ["jihijjjiiijlljihijjjjiijihjihijjjiiijlljihijjjjiijih", "jjkllkjihhijjiijjkllkjihhijihhiijhijkjhijkjhhiljjkllkjihhijihh", "hhllmmlkkjjiihllkkjjillkkjjihhllmmlkkjjiih"];

function qp_r() {
    qp_o >= qp_q[qp_n].length && (qp_o = 0, qp_n = qp_s(qp_q.length));
    return qp_q[qp_n][qp_o++]
}

function loadResource() {
    SCREEN_SHOW_ALL = !0;
    var a = new ProgressBar(0.8 * W, 40);
    a.regX = a.w / 2;
    a.regY = a.h / 2;
    a.x = W / 2;
    a.y = H / 2;
    stage.addChild(a);
    queue = new createjs.LoadQueue(!1);
    queue.setMaxConnections(30);
    loadGameData();
    queue.on("complete", qp_t, null, !0);
    USE_NATIVE_SOUND || (IS_NATIVE_ANDROID ? (createjs.Sound.registMySound("h", 0), createjs.Sound.registMySound("i", 2), createjs.Sound.registMySound("j", 4), createjs.Sound.registMySound("k", 6), createjs.Sound.registMySound("l", 8), createjs.Sound.registMySound("m", 10), createjs.Sound.registMySound("n",
        12), createjs.Sound.registMySound("silenttail", 14), queue.loadFile({
        id: "sound",
        src: RES_DIR + "audio/all.mp3"
    })) : (createjs.Sound.alternateExtensions = ["ogg"], queue.installPlugin(createjs.Sound), queue.loadManifest({
        path: RES_DIR + "/music/fans_game/",
        manifest: [{
            src: "Acoustic_Grand_Piano_01.mp3",
            id: "h"
        }, {
            src: "Acoustic_Grand_Piano_02.mp3",
            id: "i"
        }, {
            src: "Acoustic_Grand_Piano_03.mp3",
            id: "j"
        }, {
            src: "Acoustic_Grand_Piano_04.mp3",
            id: "k"
        }, {
            src: "Acoustic_Grand_Piano_05.mp3",
            id: "l"
        }, {
            src: "Acoustic_Grand_Piano_06.mp3",
            id: "m"
        }, {
            src: "Acoustic_Grand_Piano_07.mp3",
            id: "n"
        }, {
            src: "false.mp3",
            id: "over"
        }]
    }, !1)));
    // a.forQueue(queue);
    queue.load()
}

function qp_t(a) {
    qp_u();
    stage.player = new Qp_v;
    stage.addChild(stage.player);
    stage.gameoverlayer = new Qp_w;
    stage.gameoverlayer.visible = !1;
    stage.addChild(stage.gameoverlayer);
    gjQipa.onGameInit();
    gjQipa.onGameStarted()
}

function qp_u() {
    stage.background = new createjs.Shape;
    stage.background.graphics.beginFill("white").rect(0, 0, W, H);
    stage.addChild(stage.background);
    stage.background.on("mousedown", function(a) {
        IS_TOUCH && a.nativeEvent instanceof MouseEvent || qp_x(a.localX, a.localY)
    })
}

function Qp_w() {
    this.initialize();
    this.background = new createjs.Shape;
    this.background.graphics.beginFill("black").drawRect(0, 0, W, H);
    this.addChild(this.background);
    this.scoreText = new createjs.Text("\u5f97\u5206\uff1a" + score, "bold 48px Arial", "white");
    this.scoreText.x = 225;
    this.scoreText.y = 230;
    this.addChild(this.scoreText);
    this.bestText = new createjs.Text("\u6700\u9ad8\u6210\u7ee9: " + best, "bold 48px Arial", "white");
    this.bestText.x = 150;
    this.bestText.y = 380;
    this.addChild(this.bestText);
    this.bt_regame = new createjs.Text("\u91cd\u73a9", "bold 48px Arial", "white");
    this.bt_regame.x = 270;
    this.bt_regame.y = 650;
    var a;
    a = new createjs.Shape;
    a.graphics.beginFill("black").rect(0, 0, 150, 50);
    this.bt_regame.hitArea = a;
    this.bt_regame.on("click", function(a) {
        IS_TOUCH && a.nativeEvent instanceof MouseEvent || qp_y()
    });
    this.addChild(this.bt_regame);
    
    // this.bt_top = new createjs.Text("\u6392\u884c\u699c", "bold 48px Arial", "white");
    // this.bt_top.x = 240;
    // this.bt_top.y = 650;
    // a = new createjs.Shape;
    // a.graphics.beginFill("black").rect(0, 0, 150, 50);
    // this.bt_top.hitArea = a;
    // this.bt_top.on("click", function(a) {
    // 	IS_TOUCH && a.nativeEvent instanceof MouseEvent || showTop()
    // });
    this.addChild(this.bt_top)
}
Qp_w.prototype = new createjs.Container;

function qp_z(a) {
    "*" == a ? createjs.Sound.play("over", !0) : createjs.Sound.play(a, !0)
}

function qp_y() {
    stage.player.reset();
    stage.player.visible = !0;
    stage.background.visible = !0;
    stage.gameoverlayer.visible = !1;
    gjQipa.onGameStarted()
}

function qp_A() {
    stage.gameoverlayer.pushScore();
    stage.player.visible = !1;
    stage.background.visible = !1;
    stage.gameoverlayer.visible = !0;
    qp_m.visible = !1
}

function qp_B() {
    createjs.Ticker.removeEventListener("tick", qp_C);
    onNewScore();
    setTimeout("qp_A()", 150);
    gjQipa.onGameOver()
}
Qp_w.prototype.pushScore = function() {
    this.scoreText.text = "\u5f97\u5206: " + score;
    this.bestText.text = score > best ? "\u6700\u9ad8\u5f97\u5206: " + score : "\u6700\u9ad8\u5f97\u5206: " + best
};

function qp_D(a) {
    score += 1;
    stage.player.scoreText.text = score;
    qp_z(qp_r());
    qp_i[a].x = qp_f[qp_c].x;
    qp_i[a].y = qp_f[qp_c].y;
    qp_i[a].inUse = !0;
    qp_i[a].visible = !0;
    qp_f[qp_c].clicked = !0;
    qp_E()
}

function qp_x(a, b) {
    var c = qp_f[qp_c];
    qp_F(a, b) ? !0 == qp_p.visible ? (qp_p.visible = !1, qp_D(qp_G()), createjs.Ticker.addEventListener("tick", qp_C)) : qp_D(qp_G()) : b > c.y && b < c.y + qp_b && (qp_m.x = parseInt(parseInt(a) / qp_a) * qp_a, qp_m.y = c.y, qp_m.visible = !0, qp_z("*"), qp_B())
}

function qp_G() {
    var a;
    for (a = 0; a < qp_i.length; a++)
        if (!1 == qp_i[a].inUse) return a
}

function qp_F(a, b) {
    var c = qp_f[qp_c],
        d = c.y - qp_b,
        e = c.y + 2 * qp_b > H ? H : c.y + 2 * qp_b;
    return a > c.x && a < c.x + qp_a && b > d && b < e ? !0 : !1
}

function qp_E() {
    qp_c--;
    0 > qp_c && (qp_c = 4)
}

function qp_s(a) {
    return parseInt(100 * Math.random()) % a
}

function Qp_v() {
    this.initialize();
    this.genObjects()
}
Qp_v.prototype = new createjs.Container;
Qp_v.prototype.genObjects = function() {
    var a;
    qp_f = [];
    for (var b = 0; 5 > b; b++) a = new createjs.Shape, a.graphics.beginFill("black").rect(0, 0, qp_a, qp_b), a.x = qp_s(4) * qp_a, a.y = qp_b * (b - 1), a.clicked = 4 == b ? !0 : !1, this.addChild(a), 3 == b && (qp_p = new createjs.Text("\u5f00\u59cb", "bold 60px Arial", "white"), qp_p.x = a.x + 20, qp_p.y = a.y + 90, this.addChild(qp_p)), qp_f.push(a);
    qp_m = new createjs.Shape;
    qp_m.graphics.beginFill("red").rect(0, 0, qp_a, qp_b);
    qp_m.visible = !1;
    this.addChild(qp_m);
    qp_h = new createjs.Shape;
    qp_h.graphics.beginFill("yellow").rect(0,
        0, W, qp_b);
    qp_h.y = 3 * qp_b;
    this.addChild(qp_h);
    qp_i = [];
    for (a = 0; 5 > a; a++) b = new createjs.Shape, b.graphics.beginFill("grey").rect(0, 0, qp_a, qp_b), b.visible = !1, b.inUse = !1, this.addChild(b), qp_i.push(b);
    qp_g = [];
    for (b = 0; 5 > b; b++) a = new createjs.Shape, a.graphics.setStrokeStyle(1, "round").beginStroke("black").moveTo(b * qp_a, 0).lineTo(b * qp_a, H), this.addChild(a);
    for (b = 0; 6 > b; b++) a = new createjs.Shape, a.graphics.setStrokeStyle(1.5, "round").beginStroke("black").moveTo(0, (b - 1) * qp_b).lineTo(W, (b - 1) * qp_b), this.addChild(a),
        qp_g.push(a);
    this.scoreText = new createjs.Text("0", "bold 48px Arial", "red");
    this.scoreText.x = W / 2;
    this.scoreText.y = 50;
    this.addChild(this.scoreText)
};
Qp_v.prototype.reset = function() {
    qp_o = score = 0;
    qp_c = 3;
    qp_n = qp_s(qp_q.length);
    qp_d = 0;
    for (var a, b = 0; b < qp_f.length; b++) a = qp_f[b], a.x = qp_s(4) * qp_a, a.y = qp_b * (b - 1), a.clicked = 4 == b ? !0 : !1, 3 == b && (qp_p.x = a.x + 20, qp_p.y = a.y + 90, qp_p.visible = !0);
    for (b = 0; b < qp_i.length; b++) qp_i[b].inUse = !1, qp_i[b].visible = !1;
    qp_h.y = 3 * qp_b;
    qp_h.visible = !0;
    for (b = 0; b < qp_g.length; b++) qp_g[b].y = 0;
    this.scoreText.text = score
};

function qp_H() {
    return score >= qp_l ? qp_k : score * (qp_k - qp_j) / qp_l + qp_j
}

function qp_C(a) {
    var b = qp_H();
    0 == qp_d ? (qp_d = a.timeStamp, qp_e = b) : (qp_e = (a.timeStamp - qp_d) * b / 20, qp_d = a.timeStamp);
    for (a = 0; a < qp_f.length; a++) b = qp_f[a], b.y + qp_e > H ? !1 == b.clicked ? (qp_B(), b.y = -H / 4 + qp_e + b.y - H, b.x = qp_s(4) * qp_a) : (b.y = -H / 4 + qp_e + b.y - H, b.x = qp_s(4) * qp_a, b.clicked = !1) : b.y += qp_e;
    for (a = 0; a < qp_i.length; a++) b = qp_i[a], b.y + qp_e > H ? (b.y = -H / 4 + qp_e + b.y - H, b.inUse = !1, b.visible = !1) : b.y += qp_e;
    for (a = 0; a < qp_g.length; a++) b = qp_g[a], b.y = b.y + qp_e > H ? -H / 2 + qp_e + b.y - H : b.y + qp_e;
    !0 == qp_h.visible && (qp_h.y + qp_e >= H ? qp_h.visible = !1 : qp_h.y += qp_e)
};