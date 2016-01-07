class GuasController < OldCouponsController

  private
    def finished_path
      guas_activities_path
    end

    def form_name
      "guas/form"
    end

    def last_step
      4
    end
end