require 'spec_helper'
require 'pry'

RSpec.describe Dmv do
  before(:each) do
    @dmv = Dmv.new
    @facility_1 = Facility.new({name: 'DMV Tremont Branch', address: '2855 Tremont Place Suite 118 Denver CO 80205', phone: '(720) 865-4600'})
    @facility_2 = Facility.new({name: 'DMV Northeast Branch', address: '4685 Peoria Street Suite 101 Denver CO 80239', phone: '(720) 865-4600'})
    @facility_3 = Facility.new({name: 'DMV Northwest Branch', address: '3698 W. 44th Avenue Denver CO 80211', phone: '(720) 865-4600'})
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

      #NOTE: this data could change based on the API call.  It should work for the short-term, at least...
      #Don't really know how to make it 'time-proof' in that sense...
      expect(@dmv.facilities[0].name).to eq("DMV Tremont Branch")
      #This one was really rough...extra spacing and abbreviations, etc.  Good grief!
      expect(@dmv.facilities[1].address).to eq("4685 Peoria Street Suite 101 Arie P. Taylor  Municipal Bldg Denver CO 80239")
      expect(@dmv.facilities[2].phone).to eq("(720) 865-4600")
      expect(@dmv.facilities[0].services).to eq(["New Drivers License", "Renew Drivers License", "Written Test", "Road Test"])
    end

    it 'correctly create facilities array for New York based on API data' do
      newyork_facilities = DmvDataService.new.ny_dmv_office_locations()
      @dmv.create_state_facilities("New York", newyork_facilities)

      #NOTE: this data could change based on the API call.  It should work for the short-term, at least...
      #Don't really know how to make it 'time-proof' in that sense...
      expect(@dmv.facilities[0].name).to eq("Lake Placid County Office")
      #This one was really rough...extra spacing and abbreviations, etc.  Good grief!
      expect(@dmv.facilities[1].address).to eq("560 Warren Street Hudson NY 12534")
      expect(@dmv.facilities[3].phone).to eq("(718) 966-6155")
      expect(@dmv.facilities[0].services).to eq(["New Drivers License", "Renew Drivers License", "Written Test", "Road Test"])
    end

    it 'correctly create facilities array for Missouri based on API data' do
      missouri_facilities = DmvDataService.new.mo_dmv_office_locations()
      @dmv.create_state_facilities("Missouri", missouri_facilities)

      #NOTE: this data could change based on the API call.  It should work for the short-term, at least...
      #Don't really know how to make it 'time-proof' in that sense...
      expect(@dmv.facilities[0].name).to eq("Harrisonville Office")
      #This one was really rough...extra spacing and abbreviations, etc.  Good grief!
      expect(@dmv.facilities[1].address).to eq("108 N Monroe Versailles MO 65084")
      expect(@dmv.facilities[2].phone).to eq("(417) 334-2496")
      expect(@dmv.facilities[0].services).to eq(["New Drivers License", "Renew Drivers License", "Written Test", "Road Test"])
    end
  end

  describe '#get_ev_registration_analytics()' do
    it 'can retun appropriate data structure' do
      expect(@dmv.get_ev_registration_analytics("Washington", 2019)).to be_a(Hash)
    end

    it 'can generate hash with correct msot popular vehicle model' do
      #First, we need to build the vehicle regitration list and 'make' the vehicles (kept forgetting to do this!)
      factory = VehicleFactory.new()
      factory.create_vehicles(DmvDataService.new().wa_ev_registrations)

      #Now we need to register the vehicles to one or more facilities (keep it one / simple for the moment)
      #NOTE: the facility needs to have the appropriate service enabled (ARRRGH)!
      @facility_1.add_service("Vehicle Registration")

      factory.vehicles_manufactured.each do |vehicle|
        # binding.pry
        @facility_1.register_vehicle(vehicle)
      end

      #Associate the facility with the DMV:
      @dmv.add_facility(@facility_1)

      # binding.pry

      #Finally, let's look at the analytics:

      hash = @dmv.get_ev_registration_analytics("Washington", 2019)
      expect(hash[:most_popular_model]).to eq("Model 3")              #Based off of CURRENT data...could someday change
    end

    it 'can generate hash with correct # of registrations for specified year' do
      #Create the same machinery as in previous test in order to have everything set up correctly...
      factory = VehicleFactory.new()
      factory.create_vehicles(DmvDataService.new().wa_ev_registrations)
      @facility_1.add_service("Vehicle Registration")
      factory.vehicles_manufactured.each do |vehicle|
        @facility_1.register_vehicle(vehicle)
      end
      @dmv.add_facility(@facility_1)

      hash = @dmv.get_ev_registration_analytics("Washington", 2019)
      expect(hash[:number_registered_for_year]).to eq(VALUE GOES HERE)
    end
  end

end
