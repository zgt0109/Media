;
window.xutils = {};
window.xutils.color = {
    colorFormat: function(color, format) { //color[rgba format|rgb format|hex format], format["rgba"|"rgb"|"hex"]

        var expRgba = /^rgba\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d?\.?\d*)\s*\)$/i;
        var expRgb = /^rgb\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*\)$/i;
        var expHex = /(^#[\d|a-f]{3}$)|(^#[\d|a-f]{6}$)/i;

        var result = false;
        var resultColor = "error";
        var colorObj = {};
        var hexStep = 2;

        var hex = function(x) {
            return ("0" + parseInt(x).toString(16)).slice(-2);
        }

        if (result = color.match(expRgba)) {
            colorObj = {
                r: Number(result[1]),
                g: Number(result[2]),
                b: Number(result[3]),
                a: parseFloat(result[4])
            };
        } else if (result = color.match(expRgb)) {
            colorObj = {
                r: Number(result[1]),
                g: Number(result[2]),
                b: Number(result[3]),
                a: 1
            };
        } else if (result = color.match(expHex)) {
            if (color.length == 4) {
                hexStep = 1;
            }

            colorObj = {
                r: Number("0x" + color.substring(1, 1 + 1 * hexStep)),
                g: Number("0x" + color.substring(1 + 1 * hexStep, 1 + 2 * hexStep)),
                b: Number("0x" + color.substring(1 + 2 * hexStep, 1 + 3 * hexStep)),
                a: 1
            };
        }

        if (format === "rgba") {
            resultColor = "rgba(" + colorObj.r + "," + colorObj.g + "," + colorObj.b + "," + colorObj.a + ")";
        } else if (format === "rgb") {
            resultColor = "rgb(" + colorObj.r + "," + colorObj.g + "," + colorObj.b + ")";
        } else if (format == "hex") {
            resultColor = "#" + hex(colorObj.r) + hex(colorObj.g) + hex(colorObj.b);
        } else {
            resultColor = "error";
        }

        return resultColor;
    },
    colorObjToRGBA: function(o) {
        return "rgba(" + o.r + ", " + o.g + ", " + o.b + ", " + o.a + ")";
    }
};
window.xutils.swapElemInArray = function(arr, index1, index2) {
    arr[index1] = arr.splice(index2, 1, arr[index1])[0];
    return arr;
};
window.xutils.upElemInArray = function(arr, index) {
    if(index == 0) {
        return;
    }
    return xutils.swapElemInArray(arr, index, index - 1);
};
window.xutils.downElemInArray = function(arr, index) {
    if(index == arr.length -1) {
        return;
    }
    return xutils.swapElemInArray(arr, index, index + 1);
};
window.xutils.moveElemInArray = function(arr, elemIndex, toIndex) {
    var tmp = arr[elemIndex];
    arr.splice(elemIndex, 1);
    arr.splice(toIndex, 0, tmp);
    return arr;
}; 