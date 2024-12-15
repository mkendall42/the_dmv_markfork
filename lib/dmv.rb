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

  def create_state_facilities(state, facilities_incoming_data)
    #Each state may have different API, and so we need a 'dispatching' method here
    #FOR NOW: just code this for Colorado, then can break it out from there for addt'l states
    
    # #Need to extract the following information:
    # @name = facility_info[:name]
    # @address = facility_info[:address]    #Gotta concatenate all of this too...ugh...
    # @phone = facility_info[:phone]
    # @services = []
    # #Added in iteration 2
    # @collected_fees = 0
    # @registered_vehicles = []
    if state == "Colorado"
      facilities_incoming_data.each do |facility|
        facility_info = {
          name: facility[:dmv_office],
          address: "#{facility[:address_li]} #{facility[:address_1]} #{facility[:city]} #{facility[:state]} #{facility[:zip]}",
          phone: facility[:phone]
        }

        #Create facility
        new_facility = Facility.new(facility_info)
        add_facility(new_facility)

        #Now add services (to stay with spirit of preexisting codebase - even though they abandoned us!)
        #Need to convert API's listing of services to our format.  Don't think there's a cleaner way to do this than a use of 'case' or similar:
        #Can either grab the next 'token' and analyze, or search for specific terms;
        #I'll go with latter option for now
        new_facility.add_service("New Drivers License") if facility[:services_p].include?("registration")
        new_facility.add_service("Renew Drivers License") if facility[:services_p].include?("renew")
        #NOTE: they don't seem to have granularity in their services regarding tests;
        #so, I'm going to assume they offer them by default.  CHECK THIS ASSUMPTION
        new_facility.add_service("Written Test")
        new_facility.add_service("Road Test")
      end

    end

    #Just to pass initial test (super hacky for now) - just checking basic setup
    # if(state == "Colorado")
    #   @facilities = [1, 2]
    # end

  end
end
