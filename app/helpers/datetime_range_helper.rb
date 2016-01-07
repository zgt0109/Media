module DatetimeRangeHelper
  # Usage Example: 
  # datetime_range_tag f, options: {class: 'required datetimerange col-sm-6'}
  # datetime_range_tag f, start_at: :created_at_gte, end_at: :created_at_lte
  def datetime_range_tag(form, start_at: :start_at, end_at: :end_at, options: {class: 'datetimerange col-sm-12'})
    js_datetime_format   = options[:class].to_s =~ /datetimerange/ ? 'YYYY-MM-DD HH:mm' : 'YYYY-MM-DD'
    field_prefix         = form.object.is_a?(ActiveRecord::Base) ? form.object.class.name.underscore.gsub('/', '_') : 'search'
    datetime_range_field = "#{start_at}_#{end_at}"
    datetime_range_id    = "#{field_prefix}_#{datetime_range_field}"
    start_time_id        = "#{field_prefix}_#{start_at}"
    end_time_id          = "#{field_prefix}_#{end_at}"

    content_for :custom_js do
      if js_datetime_format == 'YYYY-MM-DD'
        end_time_suffix = "$('##{field_prefix}_#{end_at}').val( $('##{field_prefix}_#{end_at}').val() + ' 23:59:59')"
      end
      raw %Q(
        <script type="text/javascript">
          $('##{datetime_range_id}').on('apply.daterangepicker', function(ev, picker) {
            $('##{field_prefix}_#{start_at}').val(picker.startDate.format('#{js_datetime_format}'))
            $('##{field_prefix}_#{end_at}').val(picker.endDate.format('#{js_datetime_format}'))
            #{end_time_suffix}
          });
        </script>
      )
    end

    ruby_datetime_format    = options[:class].to_s =~ /datetimerange/ ? '%Y-%m-%d %H:%M' : '%Y-%m-%d'
    options[:placeholder] ||= '请选择时间'
    options[:id]            = datetime_range_id
    datetime_range          = [form.object.public_send(start_at).try(:strftime, ruby_datetime_format), form.object.public_send(end_at).try(:strftime, ruby_datetime_format)].compact.join(' - ')
    raw %Q(
      #{form.hidden_field start_at, id: start_time_id}
      #{form.hidden_field end_at, id: end_time_id}
      #{text_field_tag datetime_range_field, datetime_range, options}
    )
  end
end