class ShakePrize < ActiveRecord::Base
  belongs_to :site
  belongs_to :wx_user
  belongs_to :shake
  belongs_to :shake_round
  belongs_to :shake_user

  before_create :generate_code

  enum_attr :status, :in => [
    ['unused', 1, '未领奖'],
    ['used',  -1, '已领奖']
  ]

  def self.export_excel(search,shake_round_id)
    xls_report = StringIO.new
    book = ShakePrize.new_excel
    book_excel = book[0]
    book_sheet = book[1]
    export_title = ['排名', '昵称', '手机号码', '兑奖码', '状态']
    book_sheet.insert_row(0,export_title)
    #sing_sheet = []
    # sing_sheet << export_title
    search.each_with_index do |s, index|
      prize = s.shake_prizes.where(shake_round_id: shake_round_id).first
      sing_sheet = [prize.try(:user_rank), s.nickname, s.mobile, prize.try(:sn_code), prize.try(:status_name)].flatten
      book_sheet.insert_row(index+1, sing_sheet)
    end
    # sing_sheet.each_with_index do |new_sheet,index|
    #   book_sheet.insert_row(index,new_sheet)
    # end
    book_excel.write(xls_report)
    return xls_report.string
  end

  def self.new_excel
    Spreadsheet.client_encoding = "UTF-8"
    book = Spreadsheet::Workbook.new
    bold_heading = Spreadsheet::Format.new(:weight => :bold, :align => :merge)
    sheet = book.create_worksheet :name => "活动数据"
    return [book,sheet,bold_heading]
  end

  def rqrcode
    RQRCode::QRCode.new(sn_code, :size => 4, :level => :h ).to_img.resize(90, 90).to_data_url
  end

  private
    def generate_code
      self.sn_code = ::SnCodeGenerator.generate_code(self,"sn_code")
    end
end
