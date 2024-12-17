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

    facilities_incoming_data.each do |facility_data|
      #Construct facility based on state, since dataset must be converted differently due to idiosyncracies in each case
      if state == "Colorado"
        new_facility = Facility.new(facility_parameters_co(facility_data))
      elsif state == "New York"
        new_facility = Facility.new(facility_parameters_ny(facility_data))
      elsif state == "Missouri"
        new_facility = Facility.new(facility_parameters_mo(facility_data))
      end

      add_facility(new_facility)

      #Add services.  CO specifies some of them, so those must be checked (in furture rewrite, could remake initialize() to deal with this more cleanly too)
      new_facility.add_service("Written Test")
      new_facility.add_service("Road Test")
      if state == "Colorado"
        new_facility.add_service("New Drivers License") if facility_data[:services_p].include?("registration")
        new_facility.add_service("Renew Drivers License") if facility_data[:services_p].include?("renew")
      else
        new_facility.add_service("New Drivers License")
        new_facility.add_service("Renew Drivers License")
      end
    end
  end

  def get_ev_registration_analytics(state, specified_year)
    #Determine most popular make/model registered, the # registered for specified year, and the county with most registered vehicles
    #NOTE: I kept naming based on EV vehicles.  However, now that I've extended functionality to allow NY vehicles, this method is more general,
    #and can analyze general NY vehicles.  (With adjustments, it could also JUST analyze NY EV vehicles.) 

    vehicle_tally = {}
    @facilities.each do |facility|
      if facility.state == state
        facility.registered_vehicles.each do |vehicle|
          if vehicle_tally.include?(vehicle.model)      #Assume just 'model' is enough (i.e. its unique and not make + model is needed)
            vehicle_tally[vehicle.model] += 1
          else
            vehicle_tally[vehicle.model] = 1
          end
        end
      end
    end
    #Now find the largest count in the hash:
    most_popular_model = vehicle_tally.key(vehicle_tally.values.max)

    #Count number of occurences of given registration year in vehicle list
    vehicle_year_total = 0
    @facilities.each do |facility|
      if facility.state == state
        vehicle_year_total += facility.registered_vehicles.count do |vehicle|
          vehicle.registration_date.year == specified_year
        end
      end
    end

    #Find county which has the most vehicle registrations.  Note high machinery overlap with most popular model...a way to combine?
    county_tally = {}
    @facilities.each do |facility|
      if facility.state == state
        facility.registered_vehicles.each do |vehicle|
          if county_tally.include?(vehicle.registration_county)
            county_tally[vehicle.registration_county] += 1
          else
            county_tally[vehicle.registration_county] = 1
          end
        end
      end
    end
    most_popular_county = county_tally.key(county_tally.values.max)

    {most_popular_model: most_popular_model, number_registered_for_year: vehicle_year_total, county_most_registered_vehicles: most_popular_county}
  end

  def facility_parameters_co(facility_co_data)
    #Try to centralize idiosyncratic aspects of each state's dataset to specific spots in codebase
    #Alternate: could hosue this in Facility class.  Might try that another time - would require a different format since Facility wouldn't yet be initialized
    {
      name: facility_co_data[:dmv_office],
      address: "#{facility_co_data[:address_li]} #{facility_co_data[:address__1]} #{facility_co_data[:location]} #{facility_co_data[:city]} #{facility_co_data[:state]} #{facility_co_data[:zip]}",
      phone: facility_co_data[:phone],
      hours: facility_co_data[:hours]       #Iteration 4: add hours (direct copy for CO)
    }
  end

  def facility_parameters_ny(facility_ny_data)
    #To format name: have to concatenate and then 'fix' capitlization the hard way (since each word is capitalized for a title usually)
    name_formatted = facility_ny_data[:office_name].split.map { |word| word.capitalize }
    name_formatted << (facility_ny_data[:office_type].split.map { |word| word.capitalize }).join(" ")
    name_formatted = name_formatted.join(" ")

    #To format address: lots of overlap here with previous entry.  If I knew how to make a method that accepted varying arguments, I might be able to; don't know this yet...
    address_formatted = facility_ny_data[:street_address_line_1].split.map { |word| word.capitalize }
    address_formatted << facility_ny_data[:city].split.map { |word| word.capitalize }
    address_formatted << facility_ny_data[:state]
    address_formatted << facility_ny_data[:zip_code]
    address_formatted = address_formatted.join(" ")

    #Hours are listed for each day by opening and closing.  For now, I'm going to brute-force this,
    #since no exact format is expected.  This is a mess though:
    #This is gross...some facilities don't have keys for all M-F.  So I need to run ifs now (otherwise problems with nil)
    hours_formatted = ""
    if facility_ny_data.include?(:monday_beginning_hours)
      hours_formatted = "Monday: " + facility_ny_data[:monday_beginning_hours] + " - " + facility_ny_data[:monday_ending_hours] + "; "
    end
    if facility_ny_data.include?(:tuesday_beginning_hours)
      hours_formatted << "Tuesday: " + facility_ny_data[:tuesday_beginning_hours] + " - " + facility_ny_data[:tuesday_ending_hours] + "; "
    end
    if facility_ny_data.include?(:wednesday_beginning_hours)
      hours_formatted << "Wednesday: " + facility_ny_data[:wednesday_beginning_hours] + " - " + facility_ny_data[:wednesday_ending_hours] + "; "
    end
    if facility_ny_data.include?(:thursday_beginning_hours)
      hours_formatted << "Thursday: " + facility_ny_data[:thursday_beginning_hours] + " - " + facility_ny_data[:thursday_ending_hours] + "; "
    end
    if facility_ny_data.include?(:friday_beginning_hours)
      hours_formatted << "Friday: " + facility_ny_data[:friday_beginning_hours] + " - " + facility_ny_data[:friday_ending_hours]
    end

    #Some of the office don't seem to have phone numbers...make sure to process 'nil' correctly here
    phone = facility_ny_data[:public_phone_number]
    if phone != nil
      phone_formatted = "(" + phone.slice(0, 3) + ") " + phone.slice(3, 3) + "-" + phone.slice(6, 4)
    else
      phone_formatted = "not applicable"
    end

    {
      name: name_formatted,
      address: address_formatted,
      phone: phone_formatted,
      hours: hours_formatted
    }
  end

  def facility_parameters_mo(facility_mo_data)
    address_formatted = facility_mo_data[:address1].delete_suffix(",")      #Certain (random?) entries end with it for some reason
        address_formatted = "#{address_formatted} #{facility_mo_data[:city]} #{facility_mo_data[:state]} #{facility_mo_data[:zipcode]}"
        hours_formatted = facility_mo_data[:daysopen]
        if facility_mo_data.include?(:daysclosed)
          hours_formatted << " except for " + facility_mo_data[:daysclosed]
        end

        facility_info = {
          name: facility_mo_data[:name] + " Office",       #To be as consistent with other states as possible
          address: address_formatted,
          phone: facility_mo_data[:phone],
          #Add hours (may need to format a little to be consistent across states)
          #Add holidays here (since MO provides them)
          #Need :daysopen, :daysclosed; :holidaysclosed
          hours: hours_formatted,
          holidays: facility_mo_data[:holidaysclosed]
        }
  end

end
