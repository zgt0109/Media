# fetch_wmall_data({path: "/api/wmall/slide_pictures.json"}, {supplier_id: "10001"}, options = {})
@fetch_wmall_data = (api = {}, data_params, options = {}) ->
  api = $.extend(api, {host: "http://192.168.1.162:3005"})# window.location.origin
  api_url = "#{api.host}#{api.path}"
  data_params ||= {}
  result = {}

  default_options = {
    data: data_params
    async: false
    type: 'get'
    dataType: 'json'
    crossDomain: true
    #xhrFields: { withCredentials: true }
    success: (data, textStatus, jqXHR) ->
      console.log "fetch data from #{api_url}"
      result = data
    error: (data, textStatus, jqXHR) ->
      console.log "fetch data from #{api_url} is #{textStatus}"
      # result = {result: -1, result_mark: "#{textStatus}"}
      result = null
  }

  options = $.extend(default_options, options)
  $.ajax(api_url, options)

  return result

@generate_path = (path, params = {}) ->
  path ||= window.location.pathname
  auth_params = window.auth_params || {}
  params = $.extend(auth_params, params)

  return "#{path}?#{$.param(params)}"

@generate_url = (path, params = {}, host) ->
  host ||= window.location.origin
  path = generate_path(path, params)

  return "#{host}#{path}"

Array.prototype.each_slice = (step, callback) ->
  pos = 0; ref = this; slice = Array.prototype.slice; len = ref.length

  for pos in [0..len] by step
    callback.call(ref, slice.call(ref, pos, (pos+step)) )
