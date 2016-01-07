class CarOwner < ActiveRecord::Base
  mount_uploader :pic, CarPictureUploader
  img_is_exist({pic: :qiniu_pic_key}) 
  belongs_to :car_shop

  def result_day
    now = Time.now
    m_day = 90 - ((now - last_maintenance_time).to_i / 1.day)
    i_day = 365 - ((now - last_insurance_time).to_i / 1.day)
    l_day = 365 - ((now - car_license_time).to_i / 1.day)
    maintenance_day = m_day < 0 ? new_day(m_day,90) : m_day
    insurance_day = i_day < 0 ? new_day(i_day,365) : i_day
    license_day = l_day < 0 ? new_day(l_day,365) : l_day
    [maintenance_day,insurance_day,license_day]
  end

  def owner_name
    if car_full_name.present?
      car_full_name
    else
      catena = car_shop.car_catenas.where(id: car_catena_id).first.try(:name)
      type = car_shop.car_types.where(id: car_type_id).first.try(:name)
      catena.to_s + "  " + type.to_s
    end
  end

  def new_day(day,num)
  	day += num
  	if day < 0
  		new_day(day,num)
  	else
  		return day
  	end
  end
end