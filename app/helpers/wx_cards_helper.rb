module WxCardsHelper
  def fixed_begin_term_options( fixed_begin_term )
    days = [["当天",0]]
    (1 .. 90).each do |d|
      days.push(["#{d}天",d])
    end
    options_for_select(days, (fixed_begin_term ? fixed_begin_term : 0))
  end

  def fixed_term_options( fixed_term )
    days = []
    (1 .. 90).each do |d|
      days.push(["#{d}天",d])
    end
    options_for_select(days, (fixed_term ? fixed_term : 30))
  end
end
