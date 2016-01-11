# Example: VipImporting.import(Account.first, '/Users/fool/a.csv')

class VipImporting < ActiveRecord::Base
  belongs_to :site
  belongs_to :vip_user

  attr_accessor :vip_grade_names

  validates :name, :supplier_id, :vip_grade_name, presence: true
  validates :total_amount, :total_recharge_amount, :total_consume_amount, :usable_amount, :total_points, :usable_points, numericality: { greater_than_or_equal_to: 0 }, allow_blank: true
  validates :mobile,  presence: true, uniqueness: { scope: :supplier_id }
  validates :user_no, presence: true, uniqueness: { scope: :supplier_id }
  validate :vip_grade_must_exists

  HEADER_COLUMNS = %w(卡号 姓名 等级 手机号 可用金额 充值总额 消费总额 可用积分 历史总积分 开卡时间)
  HEADER_HASH = {
    '卡号'       => :user_no,
    '姓名'       => :name,
    '等级'       => :vip_grade_name,
    '手机号'     => :mobile,
    '可用金额'    => :usable_amount,
    '充值总额'    => :total_recharge_amount,
    '消费总额'    => :total_consume_amount,
    '可用积分'    => :usable_points,
    '历史总积分'  => :total_points,
    '开卡时间'    => :open_card_time
  }

  def self.validate_and_import(supplier, csv_file_path, sync: false)
    vip_importing = VipImporting.new(supplier: supplier)
    data = vip_importing.parse_data(csv_file_path)
    hash = vip_importing.validate_data(data)
    return hash if hash[:error]

    # VipImporting.import(supplier.id, csv_file_path, sync: sync)
    VipImporting.delay(queue: :standard).import(supplier.id, csv_file_path, sync: sync)
    data[:data].size
  rescue => e
    Rails.logger.error "vip importing error: #{e.message}"
    Rails.logger.error e.backtrace
    { error: true, message: '文件格式不正确' }
  end

  def self.import(supplier_id, csv_file_path, sync: false)
    VipImporting.new(supplier_id: supplier_id).import(csv_file_path, sync: sync)
  end

  def vip_grades
    vip_grades_hash = Hash[supplier.vip_grades.visible.pluck(:name, :id)]
    self.vip_grade_names = vip_grades_hash.keys
    self
  end
  
  def import(csv_file_path, sync: false)
    data = parse_data(csv_file_path)
    insert_data(data, sync: sync)
  end

  def parse_data(csv_file_path, separator: ',')
    hash = { data: [] }
    test_line = File.foreach(csv_file_path) { |line| break line }
    encoding = test_line =~ /卡号|姓名|手机号|等级/ ? 'UTF-8' : 'GBK' rescue 'GBK'
    File.foreach(csv_file_path, encoding: encoding) do |line|
      next if line.blank?
      if hash[:headers].present?
        hash[:data] << parse_fields(line, hash[:headers], separator: separator)
      else
        hash.merge!(headers: parse_headers(line, separator: separator), separators_count: line.count(separator))
      end
    end
    hash
  end

  def parse_headers(line, separator: ',')
    line.split(separator).map do |field_name|
      HEADER_HASH[field_name.strip]  
    end
  end

  def parse_fields(line, headers, separator: ',')
    line.split(separator).map.with_index.inject({line: line}) do |hash, (value, i)|
      hash.tap { |h| h[headers[i]] = value.strip if headers[i].present? }
    end
  end

  def insert_data(data, sync: false)
    total_count, sync_count = 0, 0
    vip_grades_hash = Hash[supplier.vip_grades.visible.pluck(:name, :id)]
    vip_grade_names = vip_grades_hash.keys

    data[:data].each do |attrs|
      line = attrs.delete(:line)
      attrs.merge!(supplier_id: supplier_id, vip_grade_names: vip_grade_names, vip_grade_id: vip_grades_hash[attrs[:vip_grade_name]])
      importing = VipImporting.new(attrs)
      VipImporting.where(attrs.slice(:supplier_id, :mobile)).delete_all
      if importing.save # 导入会员成功
        sync_count += 1 if sync && importing.sync_vip_user!
        total_count += 1
      else
        # 导入会员失败，记录日志
        VipImportingLog.create(error_type: 1, error_msg: importing.errors.full_messages.join('，'), line: line)
      end
    end

    VipImportingLog.create(error_type:  0, error_msg: "成功导入#{total_count}条数据") if total_count > 0
    VipImportingLog.create(error_type: -1, error_msg: "成功同步#{sync_count}条数据")  if sync_count > 0
  end

  def activate_by(user)
    return if user.blank? || supplier.vip_users.visible.where(mobile: mobile).exists?
    fields = %w(user_no name mobile vip_grade_id usable_amount total_recharge_amount total_consume_amount total_points usable_points)
    value_hash = fields.inject({}) do |h, field|
      if field == 'user_no'
        h.merge! 'custom_user_no' => attributes[field]
      else
        h.merge! field => attributes[field] || 0
      end
    end
    attrs = { user_id: user.id, is_sync: true, created_at: open_card_time }.merge!(value_hash)
    supplier.vip_users.create(attrs)
  end

  def sync_vip_user!
    vip_user = VipUser.where(is_sync: false, supplier_id: supplier_id, mobile: mobile).first
    if vip_user
      vip_user.total_points += total_points
      vip_user.usable_points += usable_points
      vip_user.usable_amount += usable_amount.to_f
      vip_user.total_recharge_amount = total_recharge_amount.to_f
      vip_user.total_consume_amount  = total_consume_amount.to_f
      vip_user.is_sync = true
      vip_user.save(validate: false)
    end
  end

  def validate_data(data)
    hash = {}
    if (HEADER_HASH.values.take(3) - data[:headers]).present?
      hash.merge!(error: true, message: '文件格式不正确')
    else
      vip_grade_names = supplier.vip_grades.visible.pluck(:name)
      data[:data].each { |attrs|
        if attrs[:vip_grade_name].blank?
          hash.merge!(error: true, message: '等级不能为空') and break
        elsif attrs[:user_no].blank?
          hash.merge!(error: true, message: '卡号不能为空') and break
        elsif attrs[:mobile].blank?
          hash.merge!(error: true, message: '手机号不能为空') and break
        elsif attrs[:name].blank?
          hash.merge!(error: true, message: '姓名不能为空') and break
        elsif !vip_grade_names.include?(attrs[:vip_grade_name])
          hash.merge!(error: true, message: '导入的等级名称无法匹配，请确认导入的等级是本系统中包含的') and break
        end
      }
    end
    hash
  end


  def vip_grade_must_exists
    vip_grades unless vip_grade_names.presence
    unless vip_grade_names.to_a.include?(vip_grade_name)
      errors.add(:vip_grade_name, '和系统已有等级不匹配')
    end
  end

end

