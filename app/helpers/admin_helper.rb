module AdminHelper
  def no_records_tag(colspan, text = '没有数据')
    raw %(<td colspan="#{colspan}" class="text-center text-success">#{text}</td>)
  end

  def show_introduce_class(current_show_introduce)
  	# current_show_introduce = current_show_introduce.to_i
   #  if current_user.show_introduce >= current_show_introduce
   #  	'miss_finish'
   #  elsif current_user.show_introduce == current_show_introduce - 1
   #  	'miss_active'
   #  else
   #  	''
   #  end
  end
end