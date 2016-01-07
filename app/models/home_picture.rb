class HomePicture < ActiveRecord::Base
 
  mount_uploader :pic, HomePicUploader
  belongs_to :admin_user

  enum_attr :pic_type, :in=>[
    ['info', 1, '新闻资讯'],
    ['company', 2, '公司动态'],
    ['qa', 3, '常见问题'],
  ]
end