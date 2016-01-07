module WxWallsHelper
  def json_for_vote_items( items, template_id = 1 )
    colors_array = [
      %W[ae6185 aec052 1bc460 aedfeb],
      %W[ff2d55 fda11c 1bc460 d7f3ea],
      %W[ff008a ff9500 1bc460 d7f3e9]
    ]
    colors = 
    items.map.with_index do |item, i|
      colors = colors_array[template_id.to_i - 1] || colors_array[0]
      color = colors[i] || colors[3]
      { 'y' => item.select_count, 'color' => "##{color}" }
    end.to_json
  end

  def vote_word_color( template_id )
    [ 'fff', '456700', 'ce3e5a' ][template_id.to_i - 1] || 'fff'
  end
end
