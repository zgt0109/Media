class WeixinCard
  class << self
    def card_pass_check(wx_mp_user, xml)
      wx_card = wx_mp_user.supplier.cards.where(card_id: xml[:CardId]).first
      wx_card.card_pass_check! if wx_card
      ''
    end

    def user_get_card(wx_user, wx_mp_user, xml)
      wx_card = wx_mp_user.supplier.cards.where(card_id: xml[:CardId]).first
      return '' unless wx_card

      consume = wx_card.consumes.where(code: xml[:UserCardCode]).first
      return '' unless consume

      return '' if consume.used?

      expired_at = wx_card.fixed_time? ? wx_card.date_info_end_at : (Date.today + wx_card.date_info_fixed_begin_term + wx_card.date_info_fixed_term)
      consume.update_attributes(status: Consume::UNUSED, expired_at: expired_at)
      # wx_mp_user.consumes.hidden.where('consumes.id <> ?', consume.id).wx_card_consumes(wx_user.id).delete_all
      wx_mp_user.consumes.hidden.where('consumes.id <> ?', consume.id).wx_card_consumes(wx_user.id).update_all(status: Consume::DELETED)
      ''
    end

    def user_del_card(wx_mp_user, xml)
      consume = wx_mp_user.consumes.where(code: xml[:UserCardCode]).first
      consume.destroy if consume
      ''
    end
  end
end