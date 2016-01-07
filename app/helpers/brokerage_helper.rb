module BrokerageHelper
	def options_types(mission_type)
		if [5,6].include?(mission_type)
			Brokerage::CommissionType::COMMISSION_TYPES.slice(*[1,2,3,4]).map(&:reverse)
		else
			Brokerage::CommissionType::COMMISSION_TYPES.slice(*[1,2]).map(&:reverse)
		end
	end

	def link_to_broker(broker,supplier)
    if broker
      link_to '立即进入', broker_mobile_brokerages_path(supplier)
    else
      link_to '立即注册', new_mobile_brokerage_path(supplier)
    end
  end
end