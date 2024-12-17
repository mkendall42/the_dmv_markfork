require 'date'

class Vehicle
  attr_reader :vin,
              :year,
              :make,
              :model,
              :engine,
              :registration_county
  attr_accessor :registration_date, :plate_type

  def initialize(vehicle_details)
    @vin = vehicle_details[:vin]
    @year = vehicle_details[:year].to_i   #Need to_i to permit proper function of antique?() method
    @make = vehicle_details[:make]
    @model = vehicle_details[:model]
    @engine = vehicle_details[:engine]
    @registration_date = nil

    #Could make a registration_data hash for compactness, but will keep vars separate to mimic interaction pattern
    @plate_type = nil
    @registration_county = vehicle_details[:county]     #This could either be set based on where car is built, OR where it's registered
  end

  def antique?
    Date.today.year - @year > 25
  end

  def electric_vehicle?
    @engine == :ev
  end
end
