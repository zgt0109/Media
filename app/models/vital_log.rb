class VitalLog

  include Mongoid::Document

  # type, content, parameters, created_at

  Type = {"auto_bind" => 1, "open_dev" => 2}

  field :type, type: Integer
  field :supplier_id, type: Integer
  field :content, type: String
  field :parameters, type: String
  field :created_at, type: DateTime

  scope :within_an_hour, where(:created_at.gte => 1.hour.ago)
  scope :by_type, ->(type){ where(:type => Type[type]) }

  class << self

    def add_log(type, supplier_id = nil, content = nil, parameters = nil)
      raise "type of vital_log named '#{type}' is not exist!" unless Type[type]
      vl = self.new
      vl.type = Type[type]
      vl.supplier_id = supplier_id
      vl.content = content.try(:to_s)
      vl.parameters = parameters.try(:to_s)
      vl.created_at = Time.now
      vl.save

      if type == "auto_bind"
        # 自动绑定失败通知
        VipUserMailer.binds_failure_notification(vl.detail).deliver
      end

    end

  end

  def detail
    ss = []
    VitalLog.fields.keys.each do |key|
      next if ["_id", "type"].include?(key)
      ss << "#{key}: #{self.try(key)}"
    end
    ss.join("\n")
  end
  
end