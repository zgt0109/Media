class SupplierPassword < ActiveRecord::Base

  validates :password_digest,
  presence: { message: '密码不能为空' },
  confirmation: { message: '' },
  length: { within: 6..6, too_short: '密码长度只能为6位数', too_long: "密码长度只能为6位数" },
  allow_blank: true

  belongs_to :supplier


  def password_question_arr
    arr = [
      ["爸爸的生日是哪天？",1],
      ["妈妈的生日是哪天？",2],
      ["小学学校的名字叫什么？",3],
      ["最喜欢的人是谁？",4],
      ["最喜欢的宠物是什么？",5],
      ["最爱听的歌是什么？",6],
      ["最难忘的事情是什么？",7],
      ["最想去的地方是哪里？",8],
    ]
    arr
  end
  
end
