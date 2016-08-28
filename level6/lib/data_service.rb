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

    def create_rental_modifications
      @rental_modifications ||= @data['rental_modifications'].map do |raw_r_mod|
        RentalModification.new(raw_r_mod)
      end
    end

    def write_output
      output = { 'rental_modifications' => @rental_modifications.map do |r_m|
          {
            id: r_m.id,
            rental_id: r_m.rental_id,
            actions: format_actions(r_m.apply_modification)
          }
        end
      }

      JSON.pretty_generate(output)
    end

    protected

    def format_actions amounts
      amounts.map do |actor, amount|
        format_action(actor, get_type(actor, amount), amount.abs)
      end
    end

    def format_action who, type, amount
      {
        who: who,
        type: type,
        amount: amount
      }
    end

    def get_type actor, amount
      inverse_type = amount < 0
      if actor == :driver
        inverse_type ? :debit : :credit
      else
        inverse_type ? :credit : :debit
      end
    end
  end
end
