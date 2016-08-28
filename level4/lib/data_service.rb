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
      output = { 'rentals' => @rentals.map do |r|
          {
            id: r.id,
            price: r.price.to_i,
            options: format_options(r),
            commission: format_commission(r)
          }
        end
      }

      JSON.pretty_generate(output)
    end

    protected

    def format_commission rental
      {
        insurance_fee: rental.insurance_fee.to_i,
        assistance_fee: rental.assistance_fee.to_i,
        drivy_fee: rental.drivy_fee.to_i
      }
    end

    def format_options rental
      {
        deductible_reduction: rental.deductible_reduction
      }
    end
  end
end
