#This tracks a specific DMV facility's core information and serviced rendered (or perhaps I should say """"""services""""""", given that it's the DMV)

class Facility
  attr_reader :name, :address, :phone, :services, :collected_fees, :registered_vehicles, :state, :hours, :holidays
  @@fee_chart = {ev: 200, antique: 25, regular: 100}      #Fun new thing.  Can use again and again (class var, not instance var)

  def initialize(facility_info)
    @name = facility_info[:name]        #@name = sanitize(facility_info)
    @address = facility_info[:address]
    @phone = facility_info[:phone]
    @services = []
    @collected_fees = 0
    @registered_vehicles = []
    #Added in iteration 4 (for by-state searching).  Default is nil, if not specified (backwards compatible methinks)
    @state = facility_info[:state]
    @hours = facility_info[:hours]
    @holidays = facility_info[:holidays]
  end

  def add_service(service)
    @services << service
  end

  def include?(service_specified)
    #NOTE: find must return 'false' if nothing found to play nice with methods accessing it
    @services.find(proc {false}) { |service| service == service_specified }
  end

  #Facility services

  def register_vehicle(vehicle)
    #Only register the vehicle if this facility offers the service!  Otherwise don't waste time with processing.
    return nil if !include?("Vehicle Registration")

    vehicle.registration_date = Date.today

    #Determine plate type and collect fees (this of course assumes the registrant has/will pay)
    if vehicle.electric_vehicle?()
      vehicle.plate_type = :ev
      @collected_fees += @@fee_chart[:ev]
    elsif vehicle.antique?()
      vehicle.plate_type = :antique
      @collected_fees += @@fee_chart[:antique]
    else
      vehicle.plate_type = :regular
      @collected_fees += @@fee_chart[:regular]
    end

    @registered_vehicles << vehicle
  end

  def administer_written_test(registrant)
    #ALL conditions must be met.  Pretty compact!
    registrant.license_data[:written] = include?("New Drivers License") && registrant.age >= 16 && registrant.permit?()
  end

  def administer_road_test(registrant)
    #Of course, this assumes the registrant actually passes the test (happy path)
    registrant.license_data[:license] = include?("Road Test") && registrant.license_data[:written] == true
  end

  def renew_drivers_license(registrant)
    registrant.license_data[:renewed] = include?("Renew License") && registrant.license_data[:license] == true
  end

end
