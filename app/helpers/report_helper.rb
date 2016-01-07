module ReportHelper
  
  def chart(categories, data, options = {})
    options.reverse_merge!(title: '日增关注数', serie_name: '新增数')
    
    LazyHighCharts::HighChart.new('basic_line') do |f|
        f.chart({
            type: 'spline'
        })
        f.title({
            text: options[:title]
        })
        f.credits({
            enabled: false
        })
        f.xAxis({
            categories: categories,
            minTickInterval:"2",
            tickmarkPlacement:"on"
        })
        f.yAxis({
            title: {
                text: ''
            },
            labels: {

            }
        })
        f.tooltip({
            crosshairs: true,
            shared: true
        })
        f.plotOptions({
            spline: {
                marker: {
                    radius: 2,
                    lineColor: '#666666',
                    lineWidth: 1
                }
            }
        })
        f.series({
                name: options[:serie_name],
                marker: {
                    symbol: 'circle'
                },
                data: data
        })
    end
  end
  
end