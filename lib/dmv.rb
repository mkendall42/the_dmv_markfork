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
          address: "#{facility[:address_li]} #{facility[:address__1]} #{facility[:location]} #{facility[:city]} #{facility[:state]} #{facility[:zip]}",
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

    #Better (refactor later): write a fetcher function that depends on state - that's the only thing that really changes here...
    #Well, there could be issues with services as well...we'll see...
    if state == "New York"
      facilities_incoming_data.each do |facility|
        #Pre-determine name, since this one is nasty, have to concatenate and then 'fix' capitlization the hard way (since each word is capitalized for a title usually)
        name_formatted = facility[:office_name].split.map { |word| word.capitalize }
        name_formatted << facility[:office_type].split.map { |word| word.capitalize }
        name_formatted.join(" ")

        #Fuck this, I'm writing a helper method to just capitalize each word.
        #I guess it will live in this class since it's not used anywhere else for this project
        #(a case where OOO is kinda weird / less 'aligned')
        #This could be tricky, though, because it needs to accept an arbitrary number of arguments (maybe pass the hash keys as symbols?).  Don't know how to do this yet...
        address_formatted = facility[:street_address_line_1].split.map { |word| word.capitalize }
        address_formatted << facility[:city].split.map { |word| word.capitalize }
        address_formatted << facility[:state]
        address_formatted << facility[:zip_code]
        address_formatted.join(" ")

        #Some of the branches don't seem to have phone numbers...make sure to process 'nil' correctly here
        if facility[:public_phone_number] != nil
          

        


        facility_info = {
          name: name_formatted
          # address: "#{facility[:address_li]} #{facility[:address__1]} #{facility[:location]} #{facility[:city]} #{facility[:state]} #{facility[:zip]}",
          # phone: facility[:phone]
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

  end
end
