class Rental < RentalBase
  include PriceService

  def update_attributes params
    params.each do |attr_key, attr_value|
      instance_variable_set(attr_key, attr_value)
    end
  end

  def delta_from_amounts old_amounts, new_amounts
    old_amounts.map do |actor, amount|
      [actor, amount - new_amounts[actor]]
    end.to_h
  end

  def price
    @price = (time_price + distance_component).to_i
  end

  def commission
    @commission = (price * 0.3).to_i
  end

  def insurance_fee
    @insurance_fee = commission / 2
  end

  def assistance_fee
    @assistance_fee = rental_days * 100
  end

  def drivy_fee
    @drivy_fee = commission - insurance_fee - assistance_fee
  end

  def compute_all_amounts
    [:driver, :owner, :insurance, :assistance, :drivy]
      .map { |actor| [actor, compute_amount(actor)] }.to_h
  end

  def compute_amount actor
    case actor
    when :driver
      price + deductible_reduction
    when :owner
      price - commission
    when :insurance
      insurance_fee.to_i
    when :assistance
      assistance_fee.to_i
    when :drivy
      (drivy_fee + deductible_reduction).to_i
    else
      0
    end
  end

  protected

  def rental_days
    @rental_days = (@end_date - @start_date).to_i + 1
  end

  def car
    @car = ObjectSpace.each_object(Car).detect { |c| c.id == @car_id }
  end
end
