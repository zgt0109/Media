# -*- encoding : utf-8 -*-
class HttpOpen

  DEFAULT_TIMEOUT = 3

  class << self

    def get(url, open_timeout, options = {})
      return {"error" => "url 不能为空!"} if url.blank?
      options[:read_timeout] ||= open_timeout
      url_str = URI.parse(URI::encode(url))
      site = Net::HTTP.new(url_str.host, url_str.port)
      site.open_timeout = open_timeout
      site.read_timeout = options[:read_timeout]
      path = url_str.query.blank? && url_str.path || url_str.path + "?" + url_str.query
      path = "/" if path.blank?
      body = site.get2(path, {'accept'=>'text/html','user-agent'=>'Mozilla/5.0'}).try(:body).to_s
      result = {"body" => body}
    rescue Exception => e
      result = {"error" => e.class, "body" => ""}
    ensure      
      return result
    end

     def agent(open_timeout, options = {})
      @agent ||= begin
        options[:read_timeout] ||= open_timeout
        agent = Mechanize.new
        # agent.auth('username', 'password')
        agent.open_timeout = open_timeout  # seconds
        agent.read_timeout = options[:read_timeout]
        agent.user_agent  ="Mozilla/5.0"
        agent
      end
    end

  end

end
