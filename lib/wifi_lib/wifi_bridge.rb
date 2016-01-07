# encoding: utf-8
class WifiLib::WifiBridge

  JAR_PATH = Rails.root.join("lib/wifi_lib", 'wifi.jar')

  class << self

    def encoding_message message 
      ret = ""   
      IO.popen("java -jar #{JAR_PATH} '#{message}' 'en' ") {|io| ret << io.read }
      ret
    end

    def decoding_message message
      ret = ""      
      IO.popen("java -jar #{JAR_PATH} '#{message}' 'de' ") {|io| ret << io.read } 
      ret
    end

  end
end
