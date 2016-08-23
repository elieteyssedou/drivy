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
    # rules for time prices calculation,
    # key is for the day the rule apply,
    # value is for the reduction in percent of the base price, from this day.
    rules = { '0' => 0, '1' => 10, '4' => 30, '10' => 50 }

    computed_prices_per_day(rules).map { |range_price| range_price * car.price_per_day }.inject(:+)
  end

  def computed_prices_per_day rules
    dates = rules.keys.map(&:to_i)
    days_count = dates.each_with_index.map do |date, i|
      number_of_days_in_range(date, dates[i+1], rental_days)
    end
    arr = days_count.zip(rules.values)
    arr.map { |elem| elem[0] * (1 - elem[1] / 100.0) }
  end

  def number_of_days_in_range i, j, rental_days
    j = rental_days if !j || rental_days < j
    (i..j - 1).size
  end

  def rental_days
    @rental_days ||= (@end_date - @start_date).to_i + 1
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
      output = { 'rentals' => @rentals.map { |r| { 'id' => r.id, 'price' => r.price.to_i } } }
      JSON.pretty_generate(output)
    end
  end
end

DataService.read_input
DataService.create_cars
DataService.create_rentals

puts DataService.write_output
