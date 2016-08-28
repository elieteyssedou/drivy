require 'json'
require 'date'

require './lib/car'
require './lib/data_service'
require './lib/price_service'
require './lib/rental'

DataService.read_input
DataService.create_cars
DataService.create_rentals

puts DataService.write_output
