class RentalBase
  attr_reader :id

  def initialize params
    @id = params['id']
    @car_id = params['car_id']
    @start_date = params['start_date'] ? Date.strptime(params['start_date']) : nil
    @end_date = params['end_date'] ? Date.strptime(params['end_date']) : nil
    @distance = params['distance']
    @deductible_reduction = params['deductible_reduction']
  end
end
