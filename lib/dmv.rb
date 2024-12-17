#Class appears to track DMV facilities and services offered to customers
require 'pry'

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

  #Larger methods below.  For future: could consider classes for DMVs in each state, to better handle
  #idiosyncracies to procedures and different dataset formats for different states.

  def create_state_facilities(state, facilities_incoming_data)
    #Each state may have different API, and so we need a 'dispatching' method here
    #FOR NOW: just code this for Colorado, then can break it out from there for addt'l states
    #Also coded for NY and MO (that's all for this project)
    if state == "Colorado"
      # hash = get_facilities_data_colorado(facilities_incoming_data)
      facilities_incoming_data.each do |facility|
        # new_facility = Facility.new(facility_parameters(facility))
        facility_info = {
          name: facility[:dmv_office],
          address: "#{facility[:address_li]} #{facility[:address__1]} #{facility[:location]} #{facility[:city]} #{facility[:state]} #{facility[:zip]}",
          phone: facility[:phone],
          hours: facility[:hours]       #Iteration 4: add hours (direct copy for CO)
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

        #Hours are listed for each day by opening and closing.  For now, I'm going to brute-force this,
        #since no exact format is expected.  This is a mess though:
        #This is gross...some facilities don't have keys for all M-F.  So I need to run ifs now (otherwise problems with nil)
        hours_formatted = ""
        #Could switch this to case / when
        if facility.include?(:monday_beginning_hours)
          hours_formatted = "Monday: " + facility[:monday_beginning_hours] + " - " + facility[:monday_ending_hours] + "; "
        end
        if facility.include?(:tuesday_beginning_hours)
          hours_formatted << "Tuesday: " + facility[:tuesday_beginning_hours] + " - " + facility[:tuesday_ending_hours] + "; "
        end
        if facility.include?(:wednesday_beginning_hours)
          hours_formatted << "Wednesday: " + facility[:wednesday_beginning_hours] + " - " + facility[:wednesday_ending_hours] + "; "
        end
        if facility.include?(:thursday_beginning_hours)
          hours_formatted << "Thursday: " + facility[:thursday_beginning_hours] + " - " + facility[:thursday_ending_hours] + "; "
        end
        if facility.include?(:friday_beginning_hours)
          hours_formatted << "Friday: " + facility[:friday_beginning_hours] + " - " + facility[:friday_ending_hours]
        end

        #Some of the branches don't seem to have phone numbers...make sure to process 'nil' correctly here
        #Also, trying to keep this consistently formatted between states
        phone = facility[:public_phone_number]
        if phone != nil
          phone_formatted = "(" + phone.slice(0, 3) + ") " + phone.slice(3, 3) + "-" + phone.slice(6, 4)
        else
          phone_formatted = "not applicable"
        end

        facility_info = {
          name: name_formatted,
          address: address_formatted,
          phone: phone_formatted,
          #Add hours (will need parsing / formatting first)
          hours: hours_formatted
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
        #Again, like NY, this formatting could be handled in another method...
        address_formatted = facility[:address1].delete_suffix(",")      #Certain (random?) entries end with it for some reason
        address_formatted = "#{address_formatted} #{facility[:city]} #{facility[:state]} #{facility[:zipcode]}"
        hours_formatted = facility[:daysopen]
        if facility.include?(:daysclosed)
          hours_formatted << " except for " + facility[:daysclosed]
        end

        facility_info = {
          name: facility[:name] + " Office",       #To be as consistent with other states as possible
          address: address_formatted,
          phone: facility[:phone],
          #Add hours (may need to format a little to be consistent across states)
          #Add holidays here (since MO provides them)
          #Need :daysopen, :daysclosed; :holidaysclosed
          hours: hours_formatted,
          holidays: facility[:holidaysclosed]
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
    
    #CRITICAL: now that there are registrations from multiple states, we need to break down by state
    #FIX THIS!!!
    #ALSO: rename the method, since it handles vehicles beyond EVs

    vehicle_tally = {}
    @facilities.each do |facility|
      #Only iterate through facilities in the specified state
      if facility.state == state

        facility.registered_vehicles.each do |vehicle|
          # binding.pry

          if vehicle_tally.include?(vehicle.model)      #Assume just 'model' is enough (i.e. its unique and not make + model is needed)
            vehicle_tally[vehicle.model] += 1           #Forgot to make this 'vehicle.model' for a while...was driving me crazy!
          else
            vehicle_tally[vehicle.model] = 1
          end
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

    #Count number of occurences of given registration year in vehicle list
    #I wonder if there are occasionally shortcuts for nested iterations...
    vehicle_year_total = 0            #Define now for scope
    @facilities.each do |facility|
      # facility.registered_vehicles.count(vehicle_to_check.registration_date.year)
      vehicle_year_total += facility.registered_vehicles.count do |vehicle|
        vehicle.registration_date.year == specified_year
      end
    end

    #Find county (in WA) which has the most vehicle registrations.
    #Very similar machinery to the first part above.  See if it's possible to refactor to combine these later?  (Would need fancier hash at least...)
    county_tally = {}
    @facilities.each do |facility|
      if facility.state == state
        facility.registered_vehicles.each do |vehicle|
          #Access vehicle's registration county here and add to tally hash
          if county_tally.include?(vehicle.registration_county)      #Assume just 'model' is enough (i.e. its unique and not make + model is needed)
            county_tally[vehicle.registration_county] += 1           #Forgot to make this 'vehicle.model' for a while...was driving me crazy!
          else
            county_tally[vehicle.registration_county] = 1
          end
        end
      end
    end
    most_popular_county = county_tally.key(county_tally.values.max)

    return {most_popular_model: most_popular_model, number_registered_for_year: vehicle_year_total, county_most_registered_vehicles: most_popular_county}
  end

end
