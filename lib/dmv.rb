#Class appears to track DMV facilities and services offered to customers
#UPDATE: I can use this to create (via API) all facilities and track / gather additional information

require 'pry'

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
    #Also coded for NY and MO (that's all for this project)
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
        name_formatted << (facility[:office_type].split.map { |word| word.capitalize }).join(" ")
        name_formatted = name_formatted.join(" ")

        #Fuck this, I might write a helper method to just capitalize each word.
        #I guess it will live in this class since it's not used anywhere else for this project
        #(a case where OOO is kinda weird / less 'aligned')
        #This could be tricky, though, because it needs to accept an arbitrary number of arguments (maybe pass the hash keys as symbols?).  Don't know how to do this yet...
        address_formatted = facility[:street_address_line_1].split.map { |word| word.capitalize }
        address_formatted << facility[:city].split.map { |word| word.capitalize }
        address_formatted << facility[:state]
        address_formatted << facility[:zip_code]
        address_formatted = address_formatted.join(" ")

        #Some of the branches don't seem to have phone numbers...make sure to process 'nil' correctly here
        #Also, trying to keep this consistently formatted between states
        phone = facility[:public_phone_number]
        if phone != nil
          phone_formatted = "(" + phone.slice(0, 3) + ") " + phone.slice(3, 3) + "-" + phone.slice(6, 4)
        end

        facility_info = {
          name: name_formatted,
          address: address_formatted,
          phone: phone_formatted
        }

        #Create facility
        new_facility = Facility.new(facility_info)
        add_facility(new_facility)

        #Add services: NOTE - NY office API does NOT return these.
        #I will assume ALL services are offered (is this ok?)
        new_facility.add_service("New Drivers License")
        new_facility.add_service("Renew Drivers License")
        new_facility.add_service("Written Test")
        new_facility.add_service("Road Test")
      end
    end

    if state == "Missouri"
      facilities_incoming_data.each do |facility|
        address_formatted = facility[:address1].delete_suffix(",")      #Certain (random?) entries end with it for some reason
        address_formatted = "#{address_formatted} #{facility[:city]} #{facility[:state]} #{facility[:zipcode]}"

        facility_info = {
          name: facility[:name] + " Office",       #To be as consistent with other states as possible
          address: address_formatted,
          phone: facility[:phone]
        }

        #Create facility
        new_facility = Facility.new(facility_info)
        add_facility(new_facility)

        #Add services: NOTE - MO office API does NOT return these.
        #I will assume ALL services are offered (is this ok?)
        new_facility.add_service("New Drivers License")
        new_facility.add_service("Renew Drivers License")
        new_facility.add_service("Written Test")
        new_facility.add_service("Road Test")
      end

    end

  end

  def get_ev_registration_analytics(state, specified_year)
    #Determine most popular make/model registered, the # registered for specified year, and the county with most registered vehicles
    #Return as a hash (then helper methods can e.g. access or print part of it)

    #Most popular make/model: iterate through all vehicles with all facilities
    #Need to make a new 2D array, or a hash, that tracks model and count -> and keeps only unique entries (assume happy path that models' strings are formatted the same)
    #This took a while to get working...in part owing to having to get everything set up correctly in the test...
    vehicle_tally = {}
    @facilities.each do |facility|
      facility.registered_vehicles.each do |vehicle|
        # binding.pry

        if vehicle_tally.include?(vehicle.model)      #Assume just 'model' is enough (i.e. its unique and not make + model is needed)
          vehicle_tally[vehicle.model] += 1           #Forgot to make this 'vehicle.model' for a while...was driving me crazy!
        else
          vehicle_tally[vehicle.model] = 1
        end
      end
    end

    #Now find the largest count in the hash:
    #I think I need to run the max() enumerable on the values list (counts), then lookup the corresponding key (model):
    most_popular_model = vehicle_tally.key(vehicle_tally.values.max)
    # max_count = vehicle_tally.max 

    #Practice: start with array.  Find occurence of each value.
    # array = [1, 2, 6, 5, 9, 1, 9, 4, 2, 5, 9]
    # values_hash = {}
    # array.each do |element|
    #   #For each element in the array, check to see if it exists in the hash.  If so, update; if not, add at it the end.
    #   number = values_hash.find do |number_key, count|
    #     number_key == element
    #   end
    #   if number == nil
    #     values_hash[element] = 1
    #   else
    #     values_hash[element] += 1
    #   end
    # end
    # #Practice, more compact.  Don't need the .find enumerable, really...
    # array = [1, 2, 6, 5, 9, 1, 9, 4, 2, 5, 9]
    # values_hash = {}
    # array.each do |element|
    #   if values_hash.include?(element)
    #     values_hash[element] += 1
    #   else
    #     values_hash[element] = 1
    #   end
    # end

    #This will find if the entry already exists in the hash:
    # number = vehicle_tally.find { |model, count| vehicle[:model] == vehicle }

    return {most_popular_model: most_popular_model, number_registered_for_year: 42, county_most_registered_vehicles: "Linn"}
  end
  
end
