module ActiveRecord
  class Base
    attr_accessor :can_validate

    def can_validate?
      !!can_validate
    end

    def self.has_time_range(start_at: :start_at, end_at: :end_at, separator: ' - ', format: nil)
      define_method "#{start_at}_#{end_at}" do
        format ||= public_send(start_at).is_a?(Date) ? '%F' : '%F %R'
        return nil if public_send(start_at).blank?
        return nil if public_send(end_at).blank?
        "#{public_send(start_at).strftime(format)} - #{public_send(end_at).strftime(format)}"
      end

      define_method "#{start_at}_#{end_at}=" do |datetime_range|
        date_arr = datetime_range.to_s.split( separator ).map!(&:strip)
        public_send "#{start_at}=", date_arr[0]
        public_send "#{end_at}=",   date_arr[1]
      end
    end

    def self.none
      scoped.extending(NullRelation)
    end

    def error_message
      errors.full_messages.first
    end

    def full_error_message(separator: '，')
      errors.full_messages.join(separator).presence
    end
  end
  
  module Calculations
    def pluck(*column_names)
      column_names = column_names.flatten.map! do |column_name|
        if column_name.is_a?(Symbol) && column_names.include?(column_name.to_s)
          column_name = "#{connection.quote_table_name(table_name)}.#{connection.quote_column_name(column_name)}"
        end
        column_name
      end

      result = klass.connection.exec_query(select(column_names).to_sql)

      result = result.map do |attributes|
        result.columns.map do |column|
          klass.type_cast_attribute(column, klass.initialize_attributes(attributes))
        end
      end
      result.flatten! if result.first.try(:length) == 1
      result
    end
  end

  module NullRelation
    def exec_queries
      @records = []
    end

    def pluck(*column_names)
      []
    end

    def delete_all(_conditions = nil)
      0
    end

    def update_all(_updates, _conditions = nil, _options = {})
      0
    end

    def delete(_id_or_array)
      0
    end

    def size
      calculate :size, nil
    end

    def empty?
      true
    end

    def any?
      false
    end

    def many?
      false
    end

    def to_sql
      ""
    end

    def count(*)
      calculate :count, nil
    end

    def sum(*)
      calculate :sum, nil
    end

    def average(*)
      calculate :average, nil
    end

    def minimum(*)
      calculate :minimum, nil
    end

    def maximum(*)
      calculate :maximum, nil
    end

    def calculate(operation, _column_name, _options = {})
      if [:count, :sum, :size].include? operation
        group_values.any? ? Hash.new : 0
      elsif [:average, :minimum, :maximum].include?(operation) && group_values.any?
        Hash.new
      else
        nil
      end
    end

    def exists?(_id = false)
      false
    end
  end
end

module I18n
  class << self
    def mt( model_name )
      t "activerecord.models.#{model_name}"
    end

    def mat( model_name, attribute_name )
      t "activerecord.attributes.#{model_name}.#{attribute_name}"
    end
  end
end
