require 'date'

#This appears to track information on an individual vehicle that would be registered with the state DMV

class Vehicle
  attr_reader :vin,
              :year,
              :make,
              :model,
              :engine,
              :registration_county
              # :registration_date,
              # :plate_type
  attr_accessor :registration_date, :plate_type

  def initialize(vehicle_details)         #Extract all data from a hash (some details are optional)
    @vin = vehicle_details[:vin]
    @year = vehicle_details[:year].to_i   #To permit proper function of antique?() method
    @make = vehicle_details[:make]
    @model = vehicle_details[:model]
    @engine = vehicle_details[:engine]
    @registration_date = nil

    #Maybe make a registration_data hash to keep as one unit?
    #For now, I WON'T do this, given the interaction pattern we're suppost to mimic...
    @plate_type = nil
    @registration_county = vehicle_details[:county]     #This is sometimes actually done when 'building' the vehicle at the factory, to satisfy interaction pattern.  Technically needs to be set when vehicle gets registered...
  end

  def antique?
    Date.today.year - @year > 25
  end

  def electric_vehicle?
    @engine == :ev
  end
end
