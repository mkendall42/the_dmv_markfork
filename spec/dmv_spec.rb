require 'spec_helper'

RSpec.describe Dmv do
  before(:each) do
    @dmv = Dmv.new
    @facility_1 = Facility.new({name: 'DMV Tremont Branch', address: '2855 Tremont Place Suite 118 Denver CO 80205', phone: '(720) 865-4600'})
    @facility_2 = Facility.new({name: 'DMV Northeast Branch', address: '4685 Peoria Street Suite 101 Denver CO 80239', phone: '(720) 865-4600'})
    @facility_3 = Facility.new({name: 'DMV Northwest Branch', address: '3698 W. 44th Avenue Denver CO 80211', phone: '(720) 865-4600'})
    @wa_facility = Facility.new({name: 'DMV Tacoma Branch', address: 'Some address', phone: '(555) 555-5555', state: "Washington"})
    @ny_facility = Facility.new({name: 'DMV Nassau Branch', address: 'Some other address', phone: '(555) 555-5556', state: "New York"})

  end

  describe '#initialize' do
    it 'can initialize' do
      expect(@dmv).to be_an_instance_of(Dmv)
      expect(@dmv.facilities).to eq([])
    end
  end

  describe '#add facilities' do
    it 'can add available facilities' do
      expect(@dmv.facilities).to eq([])
      @dmv.add_facility(@facility_1)
      expect(@dmv.facilities).to eq([@facility_1])
    end
  end

  describe '#facilities_offering_service' do
    it 'can return list of facilities offering a specified Service' do
      @facility_1.add_service('New Drivers License')
      @facility_1.add_service('Renew Drivers License')
      @facility_2.add_service('New Drivers License')
      @facility_2.add_service('Road Test')
      @facility_2.add_service('Written Test')
      @facility_3.add_service('New Drivers License')
      @facility_3.add_service('Road Test')

      @dmv.add_facility(@facility_1)
      @dmv.add_facility(@facility_2)
      @dmv.add_facility(@facility_3)

      expect(@dmv.facilities_offering_service('Road Test')).to eq([@facility_2, @facility_3])
    end
  end

  describe '#create_state_facilities' do
    it 'can create default facilities array for Colorado' do
      colorado_facilities = DmvDataService.new.co_dmv_office_locations()
      @dmv.create_state_facilities("Colorado", colorado_facilities)

      #Basic checks first
      expect(@dmv.facilities).to be_a(Array)
      expect(@dmv.facilities).to_not eq([])
    end

    it 'correctly create facilities array for Colorado based on API data' do
      colorado_facilities = DmvDataService.new.co_dmv_office_locations()
      @dmv.create_state_facilities("Colorado", colorado_facilities)

      #NOTE: I previously checked specific key-value pairs in the dataset to match, but the datasets can change (they DID for MO)
      #So, now I'll check more permanent features, but with less specificity
      expect(@dmv.facilities[0]).to be_a(Facility)
      expect(@dmv.facilities[0].name).to be_a(String)
      expect(@dmv.facilities[1].address).to be_a(String)
      expect(@dmv.facilities[2].phone.length).to eq(14)
      expect(@dmv.facilities[0].services).to be_a(Array)
      expect(@dmv.facilities[3].hours).to be_a(String)
    end

    it 'correctly create facilities array for New York based on API data' do
      newyork_facilities = DmvDataService.new.ny_dmv_office_locations()
      @dmv.create_state_facilities("New York", newyork_facilities)

      # binding.pry

      expect(@dmv.facilities[0]).to be_a(Facility)
      expect(@dmv.facilities[0].name).to be_a(String)
      expect(@dmv.facilities[1].address).to be_a(String)
      expect(@dmv.facilities[2].phone.length).to eq(14)
      expect(@dmv.facilities[0].services).to be_a(Array)
      expect(@dmv.facilities[3].hours).to be_a(String)
    end

    it 'correctly create facilities array for Missouri based on API data' do
      missouri_facilities = DmvDataService.new.mo_dmv_office_locations()
      @dmv.create_state_facilities("Missouri", missouri_facilities)

      # binding.pry
      
      #NOTE: this dataset list actually changed on me after I made tests; hence why I've moved to more 'permanent' testable aspects
      expect(@dmv.facilities[0]).to be_a(Facility)
      expect(@dmv.facilities[0].name).to be_a(String)
      expect(@dmv.facilities[1].address).to be_a(String)
      #Some office don't have a phone number listed in MO.  Need to give default string, I guess
      expect(@dmv.facilities[2].phone.length).to eq(14)
      expect(@dmv.facilities[0].services).to be_a(Array)
      expect(@dmv.facilities[3].hours).to be_a(String)
    end
  end

  describe '#get_ev_registration_analytics()' do
    it 'can retun appropriate data structure' do
      expect(@dmv.get_ev_registration_analytics("Washington", 2019)).to be_a(Hash)
    end

    it 'can generate hash with correct most popular vehicle model' do
      #First, we need to build the vehicle regitration list and 'make' the vehicles (kept forgetting to do this!)
      factory = VehicleFactory.new()
      factory.create_vehicles(DmvDataService.new().wa_ev_registrations, "Washington")

      #Now we need to register the vehicles to one or more facilities (keep it one / simple for the moment)
      #NOTE: facility needs to have the appropriate service enabled, and actually be in correct state for everything to work
      @wa_facility = Facility.new({name: 'DMV Tacoma Branch', address: 'Some address', phone: '(555) 555-5555', state: "Washington"})
      @wa_facility.add_service("Vehicle Registration")

      factory.vehicles_manufactured.each do |vehicle|
        @wa_facility.register_vehicle(vehicle)
      end

      @dmv.add_facility(@wa_facility)

      hash = @dmv.get_ev_registration_analytics("Washington", 2019)

      expect(hash[:most_popular_model]).to eq("Model 3")      #Risky - using correct model actually in the dataset to verify (could change if dataset changes)
      expect(hash[:most_popular_model]).to be_a(String)       #Safer, but doesn't truly check if method is working correctly

    end

    it 'can generate hash with correct # of registrations for specified year' do
      #Create the same machinery as in previous test in order to have everything set up correctly...
      factory = VehicleFactory.new()
      factory.create_vehicles(DmvDataService.new().wa_ev_registrations, "Washington")
      @facility_1.add_service("Vehicle Registration")
      factory.vehicles_manufactured.each do |vehicle|
        @facility_1.register_vehicle(vehicle)
      end
      @dmv.add_facility(@facility_1)

      #Because we're manually registering them now, all of them should be for 2024
      hash_2019 = @dmv.get_ev_registration_analytics("Washington", 2019)
      expect(hash_2019[:number_registered_for_year]).to eq(0)
      hash_2024 = @dmv.get_ev_registration_analytics("Washington", 2024)
      expect(hash_2024[:number_registered_for_year]).to eq(@facility_1.registered_vehicles.length)
    end

    it 'can generate hash with correct most common county registered' do
      #Create the same machinery as in previous tests in order to have everything set up correctly...
      factory = VehicleFactory.new()
      factory.create_vehicles(DmvDataService.new().wa_ev_registrations, "Washington")
      @wa_facility.add_service("Vehicle Registration")
      factory.vehicles_manufactured.each do |vehicle|
        @wa_facility.register_vehicle(vehicle)
      end
      @dmv.add_facility(@wa_facility)

      #Track county in Vehicle class; alternate would be deducing this from the facility it gets registered to, but we'd need a lookup function for zip code / similar
      #(beyond the scope of this project at this point...)
      hash = @dmv.get_ev_registration_analytics("Washington", 2019)
      expect(hash[:county_most_registered_vehicles]).to eq("King")    #Again, risky - depends on served dataset staying the same...
      expect(hash[:county_most_registered_vehicles]).to be_a(String)  #Safer, but doesn't truly see if it's working correctly
    end

    it 'can generate appropriate information for both WA and NY electric vehicles' do
      #Note: this required implementing NY vehicle registrations / creation first, of course
      #Create general stuff:
      factory = VehicleFactory.new()
      @dmv.add_facility(@wa_facility)
      @dmv.add_facility(@ny_facility)

      #Create WA vehicles and register with first facility
      factory.create_vehicles(DmvDataService.new().wa_ev_registrations, "Washington")
      @wa_facility.add_service("Vehicle Registration")
      factory.vehicles_manufactured.each do |vehicle|
        @wa_facility.register_vehicle(vehicle)
      end

      wa_hash = @dmv.get_ev_registration_analytics("Washington", 2024)

      # binding.pry

      #Check for WA
      expect(wa_hash).to be_a(Hash)
      expect(wa_hash[:county_most_registered_vehicles]).to eq("King")   #Could change

      #Create NY vehicles and register with second facility (don't have to, but it should really be in NY...)
      factory.create_vehicles(DmvDataService.new().ny_vehicle_registrations, "New York")
      @ny_facility.add_service("Vehicle Registration")
      factory.vehicles_manufactured.each do |vehicle|
        @ny_facility.register_vehicle(vehicle)
      end

      #Check for NY
      ny_hash = @dmv.get_ev_registration_analytics("New York", 2024)
      expect(ny_hash).to be_a(Hash)
      expect(ny_hash[:county_most_registered_vehicles]).to eq("SUFFOLK")    #Could change
    end

  end

end
