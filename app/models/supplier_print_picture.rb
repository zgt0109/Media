class SupplierPrintPicture < ActiveRecord::Base
  belongs_to :supplier_print_client
  validates :banner1_file, :banner2_file, :banner3_file, :small_banner1_file, :small_banner2_file, :small_banner3_file, presence: true, on: :create

  enum_attr :status, :in=>[
    ['normal', 1, '启用'],
    ['offline', -1, '禁用'],
  ]

  def banner1_file_url
    banner1_file.present? ? qiniu_image_url(banner1_file) : "/assets/bg_fm.jpg"
  end

  def banner2_file_url
    banner2_file.present? ? qiniu_image_url(banner2_file) : "/assets/bg_fm.jpg"
  end

  def banner3_file_url
    banner3_file.present? ? qiniu_image_url(banner3_file) : "/assets/bg_fm.jpg"
  end

  def small_banner1_file_url
    small_banner1_file.present? ? qiniu_image_url(small_banner1_file) : "/assets/bg_fm.jpg"
  end

  def small_banner2_file_url
    small_banner2_file.present? ? qiniu_image_url(small_banner2_file) : "/assets/bg_fm.jpg"
  end

  def small_banner3_file_url
    small_banner3_file.present? ? qiniu_image_url(small_banner3_file) : "/assets/bg_fm.jpg"
  end

  after_save :connect_edit_webservice

  protected
    def connect_edit_webservice #可以编辑设备
      url = "http://admin.weixinprint.com/inleader/services/mobileClient?wsdl"
      client = Savon.client do
        wsdl url
        namespace "http://admin.weixinprint.com/"
        endpoint "http://admin.weixinprint.com/inleader/services/mobileClient?wsdl"
      end
      response = client.call(:edit_client_info_byclient_banner, message:{
        client_id: self.supplier_print_client.client_id,
        banner1File: "#{self.banner1_file_url}-.jpg", #"#{WEBSITE_DOMAIN}#{self.bottom_img_url}",
        banner2File: "#{self.banner2_file_url}-.jpg",
        banner3File: "#{self.banner3_file_url}-.jpg",
        smallBanner1File: "#{self.small_banner1_file}-.jpg",
        smallBanner2File: "#{self.small_banner2_file}-.jpg",
        smallBanner3File: "#{self.small_banner3_file}-.jpg"
      })
      puts response
    end
end