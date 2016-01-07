# == Schema Information
#
# Table name: supplier_applies
#
#  id                   :integer          not null, primary key
#  name                 :string(255)
#  apply_type           :integer          default(1), not null
#  supplier_category_id :integer
#  status               :integer          default(0), not null
#  tel                  :string(255)
#  contact              :string(255)
#  email                :string(255)
#  qq                   :string(255)
#  agent_id             :integer
#  supplier_industry_id :integer          default(1), not null
#  business_type        :integer          default(2), not null
#  deal_status          :integer          default(1), not null
#  is_reply             :boolean          default(FALSE), not null
#  operator_id          :integer
#  admin_user_id        :integer
#  last_assign_at       :datetime
#  last_reply_at        :datetime
#  next_reply_at        :datetime
#  website              :string(255)
#  key_word             :string(255)
#  search_engine        :integer          default(0), not null
#  sales_team_scope     :integer          default(1), not null
#  service_team_scope   :integer          default(1), not null
#  province_id          :integer          default(9), not null
#  city_id              :integer          default(73), not null
#  district_id          :integer          default(702), not null
#  address              :string(255)
#  source_type          :integer          default(0), not null
#  source_other         :string(255)
#  budget_type          :integer          default(1), not null
#  budget_other         :string(255)
#  intro                :text
#  requirement_descr    :text
#  smm_descr            :text
#  smm_advantage        :text
#  description          :text
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#

class SupplierApply < ActiveRecord::Base
  validates :status, :contact, presence: true
  validates :tel, presence: true, uniqueness: { scope: [:product_agent_type, :business_type], case_sensitive: false }
  validates :name, presence: true, uniqueness: { case_sensitive: false }, if: :free?
  validates :address, presence: true, if: :free?
  validates :intro, presence: true, if: :free?
  validates_length_of :invitation_code, :minimum => 0, :maximum => 15, :allow_blank => true
  # validates :website, presence: true, if: :agency?
  validates :qq, presence: true, if: :agency?
  validates :name, presence: true, uniqueness: { case_sensitive: false }, if: :agency?
  validates :email,
  presence: { message: '邮箱不能为空' },
  format: { with: /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, message: '请输入正确的邮箱地址' },
  uniqueness: { message: '您输入的邮箱已经被注册', case_sensitive: false }, unless: :vcl_fxt?
  #validates :website, format: { with: /^(http|https):\/\/[a-zA-Z0-9].+$/, message: '地址格式不正确，必须以http(s)://开头' }
  validates :tel, format: { with: /^\d{11}$/, message: '不正确' }, if: :vcl_fxt? 
  validate :contact_validate

  belongs_to :supplier_category

  belongs_to :city
  belongs_to :province
  belongs_to :district

  before_save :format_attrs

  scope :effective, -> { where(["admin_user_id != 18"]) }

  enum_attr :admin_user_id, :in => [
    [:invalid, 18, '无效的']
  ]

  enum_attr :status, :in => [
    ['active', 0, '正常'],
    ['froze', -1, '已冻结']
  ]

  enum_attr :product_agent_type, :in => [
    ['vcl_line', 1, '微枚迪'],
    ['voa_line', 2, '优者工作圈'],
    ['yz_line', 3, '易站'],
    ['vcl_life_line', 4, '微客生活圈'],
    ['vcl_fxt', 7, '放心提']
  ]

  enum_attr :apply_type, :in => [
    ['free', 1, '免费申请'],
    ['agency', 2, '代理申请'],
    ['apply_from_qq', 3, 'QQ咨询'],
    ['apply_from_phone', 4, '电话咨询'],
    ['apply_from_others', 5, '其它'],
    ['apply_from_enroll', 6, '微报名'],
    ['apply_from_winwemedia', 7, '微枚迪']
  ]

  enum_attr :business_type, :in => [
    ['supplier_business', 1, '咨询产品'],
    ['agent_business', 2, '咨询代理'],
    ['other_business', 3, '其它'],
    ['meeting_business', 4, '会议邀约'],
    ['training', 5, '培训咨询'],
  ]

  enum_attr :budget_type, :in => [
    ['three_thousands', 1, '3千元-1万元'],
    ['ten_thousands', 2, '1万元-5万元'],
    ['fifty_thousands', 3, '5万元-10万元'],
    ['hundred_thousands', 4, '10万元以上'],
    ['other_budget', 5, '其他'],
  ]

  enum_attr :source_type, :in => [
    ['search_engine', 1, '搜索引擎'],
    ['weibo', 2, '微博'],
    ['weixin', 3, '微信'],
    ['internet_news', 4, '网络新闻媒体'],
    ['blog_bbs', 5, '博客空间论坛'],
    ['friends',6, '朋友介绍'],
    ['dayin_seller',7, '微枚迪销售员'],
    ['winwemedia_agent',8, '微枚迪代理商'],
    ['other_source',9,'其它'],
    ['pc', 10, '在线注册']
  ]

  enum_attr :service_team_scope, :in => [
    ['fifteen', 1 , '5-15人'],
    ['thirty', 2, '15－30人'],
    ['fifty', 3, '30－50人'],
    ['hundred', 4, '50－100人'],
    ['more_hundred', 5, '100人以上']
  ]

  after_create :update_sem_report

  # 更新SEM报表
  def update_sem_report
    date = Date.today
    sem = Reports::ReportSemApply.where(:date => date).first_or_create
    sem = self.count_sem(sem)
    sem.save
  end

  # 统计SEM报表
  def count_sem(sem)
    raise "sem can't be empty" unless sem
    key = "unknown"
    sem.total = sem.total + 1
    if self.invalid?
      key = "useless"
    else
      sem.effective = sem.effective + 1
      if self.agent_business? || self.agency?
        key = "agent"
      elsif self.supplier_business? || self.free?
        key = "product"
      elsif self.training?
        key = "train"
      end
      if key == "agent" || key == "product"
        sem.send("#{key}=", sem.send(key) + 1)
        if self.apply_from_qq?
          key = key + "_qq"
        elsif self.apply_from_phone?
          key = key + "_phone"
        elsif self.agent_business? || self.supplier_business? || self.agency? || self.free?
          key = key + "_apply"
        else
          key = key + "_other"
        end
      end
    end
    sem.send("#{key}=", sem.send(key) + 1)
    sem
  end

  def effective?
    self.admin_user_id != 18
  end

  def active!
    update_attributes!(status: ACTIVE)
  end

  def froze!
    update_attributes!(status: FROZE)
  end

  private

  def format_attrs
    self.source_other = nil unless self.other_source?
    self.budget_other = nil unless self.other_budget?

    # admin_user_id 23:渠道公共资源 16:产品公共资源
    if self.free?
      self.business_type = SUPPLIER_BUSINESS
      self.admin_user_id = 16
    elsif self.agency?
      self.business_type = AGENT_BUSINESS
      self.admin_user_id = 23
    end
  end

  def contact_validate
    if vcl_fxt?
      errors.add :contact, "过短，最少2个字符" unless contact =~ /^(.){7,}/
    end
  end

end
