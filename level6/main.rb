require 'json'
require 'date'

require './lib/car'
require './lib/data_service'
require './lib/price_service'
require './lib/rental_base'
require './lib/rental'
require './lib/rental_modification'

DataService.read_input
DataService.create_cars
DataService.create_rentals
DataService.create_rental_modifications

puts DataService.write_output
