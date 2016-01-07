module CarsHelper
  def cars_page?
    %w(car_shops car_catenas car_types car_bespeaks car_sellers car_owners car_assistants car_pictures).include?(controller_name)
  end
end
