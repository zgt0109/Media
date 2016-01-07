class WxShakeRound < ActiveRecord::Base
  belongs_to :supplier
  belongs_to :activity
  belongs_to :wx_shake
  has_many   :wx_shake_prizes

  enum_attr :status, :in => [
    ['stopped',    2, '已结束'],
    ['active',     1, '进行中'],
    ['pending',    0, '未开始'],
  ]

  scope :exist_at, -> {where(status: [PENDING, ACTIVE])}

  def self.export_excel(search)
    xls_report = StringIO.new
    book = WxShakeRound.new_excel
    book_excel = book[0]
    book_sheet = book[1]
    export_title = ['活动名称', '轮次', '活动时间', '参与人数']
    sing_sheet = []
    sing_sheet << export_title

    search.each do |s|
      sing_sheet << [s.activity.name, s.shake_round, s.created_at.strftime("%Y-%m-%d %H:%M:%S"), s.shake_user_num].flatten
    end
    sing_sheet.each_with_index do |new_sheet,index|
      book_sheet.insert_row(index,new_sheet)
    end
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

  def first_or_create_wx_shake_prize(wx_shake_user, user_rank)
    wx_shake_prizes.where(
        supplier_id:      supplier_id,
        wx_user_id:       wx_shake_user.wx_user_id,
        wx_shake_id:      wx_shake_id,
        wx_shake_user_id: wx_shake_user.id,
        user_rank:        user_rank
    ).first_or_create
  end

end
