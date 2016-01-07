class Settings < Settingslogic
  source "#{Rails.root}/config/services.yml"
  namespace Rails.env
end