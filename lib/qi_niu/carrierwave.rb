module ImageExist

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods

    def img_is_exist(options)

      return if options.blank?

      class_eval(%Q{
        def get_new_image_column(old_image_column)
            #{options}[old_image_column.to_sym]
        end
      })

      options.each do |key, value|
        class_eval(%Q{

          def #{key}
            qiniu_image_column = get_new_image_column("#{key}")
            qiniu_key = self.try(qiniu_image_column)
            qiniu_key.present? ? ImageQiniu.new(qiniu_key) : super
          end

          def #{key}?
            self.#{value}.present? || self.#{key}.url.present?
          end

          def #{key}_url
            #{key}.to_s
          end

        })
      end

    end

    def qiniu_image_for(field_name, key_prefix: nil)
      define_method "#{field_name}_url" do |**options|
        field_value = public_send(field_name)
        return if field_value.blank?
        img_url = qiniu_image_url("#{key_prefix}#{field_value}")
        if img_url.present? && options[:size].present?
          width, height = options[:size].split('x')
          img_url = "#{img_url}?imageView/2/w/#{width}/h/#{height}"
        end
        img_url
      end

      define_method "#{field_name}?" do
        public_send(field_name).present?
      end
    end

  end
end

ActiveRecord::Base.send(:include, ImageExist)
