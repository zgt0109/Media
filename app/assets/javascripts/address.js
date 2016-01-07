// 选择省份和城市类型
// app/helpers/application_helper.rb line 39 def province_select(name)
// function address_select() {
//   $('#province').change( function() {
//     var province = $(this).val();
//     var options = provinces[province];
//     var $city_select = $('#city');
//     var $district_select = $('#district');
//     $city_select.empty();
//     $district_select.empty();

//     if (options) {
//       for(var i = 0; i < options.length; i++) {
//         $city_select.append("<option value='"+options[i][1]+"'>"+options[i][0]+"</option>");
//       }
//       $city_select.filter('option:eq(0)').selected = true;

//       $('#city').trigger('change');
//     }
//   });

//   $('#city').change( function() {
//     var city = $(this).val();
//     var options = cities[city];
//     var $district_select = $('#district');
//     $district_select.empty();

//     if (options) {
//       for(var i = 0; i < options.length; i++) {
//         $district_select.append("<option value='"+options[i][1]+"'>"+options[i][0]+"</option>");
//       }
//       if(options.length == 0){
//          $district_select.append("<option value='-1'></option>");
//       }
//       $district_select.filter('option:eq(0)').selected = true;
//     }
//   });
// }

// $(address_select);

function address_select() {
  $('#province').change( function() {
    var province_id = $(this).val();
    var $city_select = $('#city');
    var $district_select = $('#district');
    $city_select.empty();
    $district_select.empty();
    var get_url = "/addresses/cities?province_id=" + province_id;
    $.get(get_url, function(data) {
      for(var i = 0; i < data.citys.length; i++) {
        $city_select.append("<option value='"+data.citys[i][1]+"'>"+data.citys[i][0]+"</option>");
      }
      $city_select.filter('option:eq(0)').selected = true;
      $("#city").change();
    });
  });

  $('#city').change( function() {
    var city_id = $(this).val();
    var $district_select = $('#district');
    $district_select.empty();
    var get_url = "/addresses/districts?city_id=" + city_id;
    $.get(get_url, function(data) {
      for(var i = 0; i < data.districts.length; i++) {
        $district_select.append("<option value='"+data.districts[i][1]+"'>"+data.districts[i][0]+"</option>");
      }
      if(data.districts.length == 0){
         $district_select.append("<option value='-1'></option>");
      }
      $district_select.filter('option:eq(0)').selected = true;
    });
  });
}

$(address_select);