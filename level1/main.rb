require 'json'
require 'date'

class Car
  attr_reader :id, :price_per_day, :price_per_km

  def initialize params
    @id = params['id']
    @price_per_day = params['price_per_day']
    @price_per_km = params['price_per_km']
  end
end

class Rental
  attr_reader :id

  def initialize params
    @id = params['id']
    @car_id = params['car_id']
    @start_date = Date.strptime params['start_date']
    @end_date = Date.strptime params['end_date']
    @distance = params['distance']
  end

  def price
    @price ||= time_price + distance_component
  end

  protected

  def time_price
    rental_days * car.price_per_day
  end

  def rental_days
    (@end_date - @start_date).to_i + 1
  end

  def distance_component
    @distance * car.price_per_km
  end

  def car
    @car ||= ObjectSpace.each_object(Car).detect { |c| c.id == @car_id }
  end
end

module DataService
  class << self
    def read_input file_path='data.json'
      unless @data
        raw_file = File.read(file_path)
      end
      @data ||= JSON.parse(raw_file)
    end

    def create_cars
      @cars ||= @data['cars'].map { |raw_car| Car.new(raw_car) }
    end

    def create_rentals
      @rentals ||= @data['rentals'].map { |raw_rental| Rental.new(raw_rental) }
    end

    def write_output
      output = { 'rentals' => @rentals.map { |r| { 'id' => r.id, 'price' => r.price } } }
      JSON.pretty_generate(output)
    end
  end
end

DataService.read_input
DataService.create_cars
DataService.create_rentals

puts DataService.write_output
