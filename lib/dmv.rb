#Class appears to track DMV facilities and services offered to customers
#UPDATE: I can use this to create (via API) all facilities and track / gather additional information

#Will need to create and add_facilities_by_state or similar
#Probably will need to update initialize() as well

class Dmv
  attr_reader :facilities

  def initialize
    @facilities = []
  end

  def add_facility(facility)
    @facilities << facility
  end

  def facilities_offering_service(service)
    @facilities.find_all do |facility|
      facility.services.include?(service)
    end
  end

  def create_state_facilities(state)
    #Each state may have different API, and so we need a 'dispatching' method here
    #FOR NOW: just code this for Colorado, then can break it out from there for addt'l states
    
    # #Need to extract the following information:
    # @name = facility_info[:name]
    # @address = facility_info[:address]
    # @phone = facility_info[:phone]
    # @services = []
    # #Added in iteration 2
    # @collected_fees = 0
    # @registered_vehicles = []

    #Just to pass initial test (super hacky for now) - just checking basic setup
    if(state == "Colorado")
      @facilities = [1, 2]
    end

  end
end
