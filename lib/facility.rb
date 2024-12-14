#This clearly tracks a specific DMV facility's core information and serviced rendered (or perhaps I should say """"""services""""""")

class Facility
  attr_reader :name, :address, :phone, :services, :collected_fees, :registered_vehicles
  @@fee_chart = {ev: 200, antique: 25, regular: 100}      #Can use again and again (class var, not instance var)

  def initialize(facility_info)    #Accepts a hash as argument
    @name = facility_info[:name]
    @address = facility_info[:address]
    @phone = facility_info[:phone]
    @services = []
    #Added in iteration 2
    @collected_fees = 0
    @registered_vehicles = []
  end

  def add_service(service)
    @services << service
  end

  def include?(service_specified)
    #Check to see if this facility provides this service
    #NOTE: find must return 'false' if nothing found to play nice with methods accessing it
    @services.find(proc {false}) { |service| service == service_specified }
  end

  #Facility services

  def register_vehicle(vehicle)
    #Only register the vehicle if this facility offers the service!  Otherwise don't waste time with processing.
    return nil if !include?("Vehicle Registration")

    #To consider later: perhaps make method designed to assign date and plate type at once (and get rid of attr_accessor)

    #Timestamp the registration
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
    #Another refactor: I think this is still clear enough
    registrant.license_data[:written] = include?("New Drivers License") && registrant.age >= 16 && registrant.permit?()
    
    #Refactor into single line boolean (note that include?() must return 'false' not 'nil' for no find)
    # if include?("New Drivers License") && registrant.age >= 16 && registrant.permit?()
    #   #Also need to update registrant's data in this case:
    #   registrant.license_data[:written] = true
    #   return true
    # else
    #   return false
    # end

    # #Verify it can be administered here
    # return false if !include?("New Drivers License") ||        #nil vs false?
    # #Verify registrant meets requirements
    # return true if (registrant.age >= 16 && registrant.permit?())
  end

  # def administer_road_test(registrant)
  # end

end
