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
            actions: format_actions(r)
          }
        end
      }

      JSON.pretty_generate(output)
    end

    protected

    def format_actions rental
      { driver: :debit,
        owner: :credit,
        insurance: :credit,
        assistance: :credit,
        drivy: :credit }
        .map do |who, type|
          format_action(who, type, compute_amount(who, rental))
        end
    end

    def format_action who, type, amount
      {
        who: who,
        type: type,
        amount: amount
      }
    end

    def compute_amount actor, rental
      case actor
      when :driver
        rental.price + rental.deductible_reduction
      when :owner
        rental.price - rental.commission
      when :insurance
        rental.insurance_fee
      when :assistance
        rental.assistance_fee
      when :drivy
        (rental.drivy_fee + rental.deductible_reduction)
      else
        0
      end
    end
  end
end
