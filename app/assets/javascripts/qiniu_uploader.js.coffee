@po = (obj,property,func) ->
  str = ""
  for prop of obj
    if typeof(obj[prop]) != 'function'
      if property != false
        str += prop + ":" + obj[prop] + "\n"
      else if func != false
        str += prop + ":" + typeof(obj[prop]) + "\n"
  str

@html2text = (html) ->
  return $('<div>' + html + '</div>').text()

unique_id = (length = 16) ->
  id = ""
  id += Math.random().toString(36).substr(2) while id.length < length
  id.substr 0, length

@standalone_panorama_uploader = () ->
  uploader_ele = $('.standalone_panorama_uploader')
  bucket = uploader_ele.data("bucket")
  uploader_ele.fileupload
    progress: (e, data) ->
      progress_ratio = parseInt(data.loaded / data.total * 100, 10)
      $(this).siblings(".upload_progress").text "#{progress_ratio}%" if progress_ratio < 100
    done: (e, data) ->
      origin_file_name = data.files[0].name
      key = data.result.key
      $(this).siblings("input").first().val("http://#{bucket}.winwemedia.com/#{key}")
      $(this).siblings("input").eq(1).val(origin_file_name)
      $(this).siblings(".upload_progress").text "#{origin_file_name} 已上传"

@music_uploader = () ->
  uploader_ele = $('.music_uploader')
  bucket = uploader_ele.data("bucket")
  uploader_ele.fileupload
    progress: (e, data) ->
      progress_ratio = parseInt(data.loaded / data.total * 100, 10)
      $(this).siblings(".upload_progress").text "#{progress_ratio}%" if progress_ratio < 100
    done: (e, data) ->
      origin_file_name = data.files[0].name
      key = data.result.key
      $(this).siblings("input").first().val("http://#{bucket}.winwemedia.com/#{key}")
      $(this).siblings("input").eq(1).val(origin_file_name)
      $(this).siblings(".upload_progress").text "#{origin_file_name}"

@single_picture_uploader = () ->
  uploader_ele = $('.single_picture_uploader')
  bucket = uploader_ele.data("bucket")
  uploader_ele.fileupload
    progress: (e, data) ->
      preview_ele =  $(this).parent().parent().find(".upload-img span img")
      progress_ratio = parseInt(data.loaded / data.total * 100, 10)
      preview_ele.attr("alt", "#{progress_ratio}%")
      preview_ele.attr("src", "")
    done: (e, data) ->
      preview_ele =  $(this).parent().parent().find(".upload-img span img")
      key = data.result.key
      $(this).siblings(".hidden").find("input").first().val(key)
      preview_ele.attr("src", "http://#{bucket}.winwemedia.com/#{key}")

