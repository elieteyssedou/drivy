module PriceService
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

  def distance_component
    @distance * car.price_per_km
  end
end
