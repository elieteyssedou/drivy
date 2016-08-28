class Rental
  attr_reader :id
  include PriceService

  def initialize params
    @id = params['id']
    @car_id = params['car_id']
    @start_date = Date.strptime params['start_date']
    @end_date = Date.strptime params['end_date']
    @distance = params['distance']
    @deductible_reduction = params['deductible_reduction']
  end

  def price
    @price ||= (time_price + distance_component).to_i
  end

  def commission
    @commission ||= (price * 0.3).to_i
  end

  def insurance_fee
    @insurance_fee ||= commission / 2
  end

  def assistance_fee
    @assistance_fee ||= rental_days * 100
  end

  def drivy_fee
    @drivy_fee ||= commission - insurance_fee - assistance_fee
  end

  protected

  def rental_days
    @rental_days ||= (@end_date - @start_date).to_i + 1
  end

  def car
    @car ||= ObjectSpace.each_object(Car).detect { |c| c.id == @car_id }
  end
end
