class CustomField < ActiveRecord::Base
  acts_as_list scope: [ :customized_id, :customized_type, :status]

  belongs_to :customized, polymorphic: true
  has_many :custom_values, :dependent => :delete_all
  serialize :possible_values

  validates :name, :field_type, presence: true

  scope :vip_card,  -> { where(customized_type: 'VipCard') }
  scope :visible,  -> { where(visible: true) }
  scope :sorted, -> { order('position ASC') }

  attr_accessible :field_type, :position, :name, :field_format, :possible_values, :name, :value, :status, :editable, :is_required, :customized_id, :customized_type, :placeholder

  enum_attr :status, :in => [
    ['normal', 1, '正常'],
    ['deleted', -1, '已删除']
  ]

  def self.system_options
    {
      '性别' => {'values' => %w(男 女 其他), 'format' => 'select', 'placeholder' => '请输入信息'},
      '年龄' => {'values' => [], 'format' => 'integer', 'placeholder' => '请输入信息'},
      '生日' => {'values' => [], 'format' => 'datetime', 'placeholder' => '请输入信息'},
      '身高' => {'values' => [], 'format' => 'integer', 'placeholder' => '请输入信息'},
      '体重' => {'values' => [], 'format' => 'integer', 'placeholder' => '请输入信息'},
      '婚姻状况' => {'values' => %w(未婚 已婚 离异), 'format' => 'select', 'placeholder' => '请输入信息'},
      '血型' => {'values' => %w(A型 B型 O型 AB型), 'format' => 'select', 'placeholder' => '请输入信息'},
      '生肖' => {'values' => %w(鼠 牛 虎 兔 蛇 马 羊 猴 鸡 狗 猪 龙), 'format' => 'select', 'placeholder' => '请输入信息'},
      '星座' => {'values' => %w(白羊座 金牛座 双子座 巨蟹座 狮子座 处女座 天秤座 天蝎座 射手座 摩羯座 水瓶座 双鱼座), 'format' => 'select', 'placeholder' => '请输入信息'},
      '职业' => {'values' => [], 'format' => 'string', 'placeholder' => '请输入信息'},
      '学历' => {'values' => %w(小学 初中 高中 大专 本科 硕士 博士 教授), 'format' => 'select', 'placeholder' => '请输入信息'},
      '邮编' => {'values' => [], 'format' => 'string', 'placeholder' => '请输入信息'},
      '住址' => {'values' => [], 'format' => 'string', 'placeholder' => '请输入信息'}
    }
  end

  def self.custom_options
    {
      '单行文本' => {'values' => %w(), 'format' => 'string', 'field_type' => 'string',  'placeholder' => '请输入信息'},
      '多行文本' => {'values' => %w(), 'format' => 'text', 'field_type' => 'string',  'placeholder' => '请输入信息'},
      '单选框' => {'values' => %w(), 'format' => 'radio', 'placeholder' => '请输入信息'},
      '复选框' => {'values' => %w(), 'format' => 'checkbox', 'placeholder' => '请输入信息'},
      '下拉框' => {'values' => %w(), 'format' => 'select', 'placeholder' => '请输入信息'},
      '日期和时间' => {'values' => %w(), 'format' => 'datetime', 'placeholder' => '请输入信息'},
    }
  end

  # id_value_array(id: custom_field.id, value: custom_value.value), for example: [ [1, '张三'], [2, '男'] ]
  def self.create_or_update_for_vip_user(vip_user, id_value_array)
    return if id_value_array.blank? || vip_user.blank?
    transaction {
      id_value_array.to_a.each do |custom_field_id, values|
        values = [*values]
        custom_field = find(custom_field_id)
        custom_field.custom_values.where(vip_user_id: vip_user.id).delete_all if custom_field.field_type == "复选框"
        values.each do |value|
          custom_value = if custom_field.field_type == "复选框"
            custom_field.custom_values.create(vip_user_id: vip_user.id, value: value)
          else
            custom_field.custom_values.where(vip_user_id: vip_user.id).first_or_create(value: value)
          end
          custom_value.update_attributes(value: value) if custom_value.value != value
        end
      end
    }
  end

  def possible_options
    possible_values.first.split(',') rescue []
  end

  def field_format=(arg)
    # cannot change format of a saved custom field
    super if new_record?
  end

  def possible_values(obj=nil)
    case field_format
    when 'bool'
      ['1', '0']
    else
      values = super()
      if values.is_a?(Array)
        values.each do |value|
          value.force_encoding('UTF-8') if value.respond_to?(:force_encoding)
        end
      end
      values || []
    end
  end

  # Makes possible_values accept a multiline string
  def possible_values=(arg)
    if arg.is_a?(Array)
      super(arg.compact.collect(&:strip).select {|v| !v.blank?})
    else
      self.possible_values = arg.to_s.split(/[\n\r]+/)
    end
  end

  def custom?
    CustomField.custom_options.key?(field_type)
  end

  def common?
    !custom?
  end

end
