//= require jquery
//= require jquery_ujs
//= require bxslider.min
//= require highcharts/highcharts
//= require Marquee
//= require luckDraw
//= require lib/iscroll


// 消息滚动
function msgLoad(el,html,direction,num){
    var $this = $(el),
        $thisH = $this.height(),
        $childH = $this.find("li").outerHeight(),
        $totalNum = $thisH/$childH,
        $showNum = num ? num : $thisH/$childH,
        $scrollBox = $this.find("ul"),
        $scrollTop = $scrollBox.css("top"),
        $scrollAmount = $showNum*$childH;
    if(direction == "top"){
        $scrollBox.prepend(html);
        $scrollBox.css("top",-$scrollAmount).animate({top:0},500,function(){
            $scrollBox.find("li:gt("+($totalNum-1)+")").remove();
        });
    }else if(direction == "start"){
        $scrollBox.prepend(html).css("top",-$scrollAmount);
        $scrollBox.animate({top:0},500,function(){
            $scrollBox.find("li:gt("+($totalNum -1)+")").remove();
        });
    }else if(direction == "end"){
        $scrollBox.append(html);
        $scrollBox.animate({top:-$scrollAmount},500,function(){
            $scrollBox.find("li:lt("+$showNum+")").remove();
            $scrollBox.css("top",0);
        });
    }else{
        $scrollBox.append(html);
        $scrollBox.animate({top:-$scrollAmount},500,function(){
            $scrollBox.find("li:lt("+$showNum+")").remove();
            $scrollBox.css("top",0);
        });
    }
}


// 投票
function showVoteChart(categories, json_data, word_color) {
  $('#container').highcharts({
    credits:false,
      chart: {
          type: 'column',
          margin: [10],
          backgroundColor: 'transparent'
      },
      title: {
          text: ''
      },
      xAxis: {
        type: 'category',
          categories: categories,
          lineWidth: '2',
          labels: {
              align: 'center',
              y: 20,
              style: {
                  fontSize: '18px',
                  fontFamily: 'microsoft yahei, sans-serif',
                  color:'#'+word_color
              }
          },
      },
      yAxis: {
          min: 0,
          minorGridLineWidth: 0,
          gridLineWidth: 0,
          title: {
              text: ''
          },
          labels:{
            enabled: false
          }
      },
      legend: {
          enabled: false
      },
      plotOptions: {
        bar: {
          borderColor: '#fff',
          borderWidth: 2,
        },
        column:{
          pointPadding: 0.2,
          borderColor: '#fff',
          borderWidth: 2,
          pointWidth: 30,
        }
      },
      tooltip: {
        enabled:false,
          pointFormat: '<b>{point.y:.1f}%</b>',
      },
      series: [{
          name: 'Population',
          data: json_data,
          dataLabels: {
              enabled: true,
              rotation: 0,
              color: '#'+word_color,
              align: 'center',
              text: '%',
              x: 0,
              y: -25,
              style: {
                  fontSize: '18px',
                  fontFamily: 'Microsoft yahei, sans-serif'
              },
              formatter: function() {
                  return this.y +'票';
              }
          }
      }]
  });
}
