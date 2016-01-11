class PayAccount < ActiveRecord::Base
  belongs_to :account
  belongs_to :city
  belongs_to :province
  has_many :pay_withdraws
  has_many :pay_transactions

  enum_attr :status, :in => [
    ['progressing',  -3, '申请中'],
    ['pending',  0, '待审核'],
    ['normal',    1, '开通'],
    ['freeze',   -1, '已冻结'],
    ['denied',    -2, '未通过']
  ]

  attr_accessor :step1, :step2, :step3

  validates :account_id, :company_name, :business_lisence, :business_address, :business_affilicated_to, :business_scope, :organization_code,
            :business_lisence_pic_key, presence: true, if: :step1
  validates :contact, :identity_type, :identity_number, :email, :identity_avaliable_to, :identity_pic_key, :tel, presence: true, if: :step2
  validates  :bank_name, :bank_account, :bank_branch, :username, :province_id, :city_id, presence: true, if: :step3

  def business_lisence_pic_url
    qiniu_image_url(business_lisence_pic_key)
  end

  def identity_pic_url
    qiniu_image_url(identity_pic_key)
  end

end

