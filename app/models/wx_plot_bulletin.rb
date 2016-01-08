class WxPlotBulletin < ActiveRecord::Base
  belongs_to :wx_plot

  validates :title, :content, presence: true
  validates :subtitle, presence: true, if: :show_content?

  before_save :add_default_attrs
  after_save :add_done_date_at

  attr_accessor :is_delete_pic

  enum_attr :status, :in => [
      ['wait', 0, '待发布'],
      ['done', 1, '已发布']
  ]

  enum_attr :subtitle_type, :in => [
      ['no_show', 0, '不显示副标题'],
      ['show_created_at', 1, '副标题显示为创建时间'],
      ['show_content', 2, '副标题显示为内容']
  ]

  %i(wait done).each do |method_name|
    class_eval(%Q{
      def #{method_name}!
        update_attributes!(status: #{method_name.upcase})
      end
    })
  end

  def pic
    qiniu_image_url(read_attribute("pic_key"))
  end

  private
    def add_default_attrs
      if self.no_show?
        self.subtitle = nil
      elsif self.show_created_at?
        self.subtitle = self.created_at.present? ? self.created_at : Time.now
      end
    end

    def add_done_date_at
      return unless self.done?
      self.update_column('done_date_at', Time.now)
    end

    def self.update_done_date_at
      WxPlotBulletin.find_each{|m| m.update_column('done_date_at', m.created_at) unless m.done_date_at}
    end

end