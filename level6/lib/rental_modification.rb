class RentalModification < RentalBase
  attr_reader :rental_id

  def initialize params
    super
    @rental_id = params['rental_id']
  end

  def apply_modification
    old_amounts = rental.compute_all_amounts
    rental.update_attributes(prepare_modification)
    rental.delta_from_amounts(old_amounts, rental.compute_all_amounts)
  end

  def rental
    @rental ||= ObjectSpace.each_object(Rental).detect { |r| r.id == @rental_id }
  end

  protected

  def prepare_modification
    mods = {}
    instance_variables.each do |attribute|
      next if attribute == :@id || attribute == :@rental_id
      mod_var = instance_variable_get(attribute)
      next if mod_var == rental.instance_variable_get(attribute)
      mods[attribute] = mod_var
    end
    mods.delete_if { |_key, value| value.nil? }
  end
end
