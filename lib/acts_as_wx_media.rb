module ActsAsWxMedia

  extend ActiveSupport::Concern

  module ClassMethods

    def acts_as_wx_media media_attribute, options = {}
      wx_media media_attribute, options
    end

    def wx_media media_attribute, options

      define_method "#{media_attribute}=" do |attribute|
        if attribute.to_s =~ /\Ahttp/
          code, result, response_headers = QiniuUploader.upload(attribute)
          write_attribute media_attribute, result['key'] if code == 200
        else
          write_attribute media_attribute, attribute
        end
      end

      define_method media_attribute do
        media_key_or_url = read_attribute(media_attribute)
        return media_key_or_url if media_key_or_url.to_s =~ /\Ahttp/
        qiniu_image_url(media_key_or_url)
      end

      #you can alias methods with options[:alias_method]
      if options[:alias_method].present?
        alias_name = options[:alias_method]
        alias_method "#{alias_name}=", "#{media_attribute}="
        alias_method "#{alias_name}", "#{media_attribute}"
      end

    end

  end


end

ActiveRecord::Base.send(:include, ActsAsWxMedia)