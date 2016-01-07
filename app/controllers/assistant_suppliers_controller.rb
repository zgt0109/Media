class AssistantSuppliersController < ApplicationController

  def toggle
    attrs = Hash.new
    attrs['assistant_id'] = params["id"]
    attrs['supplier_id'] = current_user.id
    @assistant_supplier = AssistantsSupplier.where(attrs).first
    if @assistant_supplier
      @assistant_supplier.destroy
    else
      @assistant_supplier = AssistantsSupplier.create(attrs)
    end
    render nothing: true
  end

end
