require 'spec_helper'

RSpec.describe VehicleFactory do
  before(:each) do
    @factory = VehicleFactory.new()
    @dds = DmvDataService.new()
    @registration_data_list = @dds.wa_ev_registrations

    # @facility_1 = Facility.new({name: 'DMV Tremont Branch', address: '2855 Tremont Place Suite 118 Denver CO 80205', phone: '(720) 865-4600'})
    # @facility_2 = Facility.new({name: 'DMV Northeast Branch', address: '4685 Peoria Street Suite 101 Denver CO 80239', phone: '(720) 865-4600'})

    # @cruz = Vehicle.new({vin: '123456789abcdefgh', year: 2012, make: 'Chevrolet', model: 'Cruz', engine: :ice})
    # @bolt = Vehicle.new({vin: '987654321abcdefgh', year: 2019, make: 'Chevrolet', model: 'Bolt', engine: :ev})
    # @camaro = Vehicle.new({vin: '1a2b3c4d5e6f', year: 1969, make: 'Chevrolet', model: 'Camaro', engine: :ice})

    # @registrant_1 = Registrant.new("Bruce", 18, true)
    # @registrant_2 = Registrant.new("Penny", 16)
    # @registrant_3 = Registrant.new("Tucker", 15)
  end

  describe '#initialize' do
    it 'can initialize' do
      expect(@factory).to be_a(VehicleFactory)
      expect(@factory.vehicles_manufactured).to eq([])

      # expect(@facility_1).to be_an_instance_of(Facility)
      # expect(@facility_1.name).to eq('DMV Tremont Branch')
      # expect(@facility_1.address).to eq('2855 Tremont Place Suite 118 Denver CO 80205')
      # expect(@facility_1.phone).to eq('(720) 865-4600')
      # expect(@facility_1.services).to eq([])
    end
  end

  describe '#create_vehicles()' do
    #NOTE: not sure how exhaustive this test is.  I could look and verify a couple of indices to be really sure (but again, then it's dependent upon the dataset not changing!)
    it 'can create vehicles from acquired vehicle registration list for WA' do
      #Check that the list looks about right
      expect(@registration_data_list.size).to be_a(Integer)   #Like in other spec file.  Don't know why it wouldn't be an integer...
      expect(@registration_data_list).to be_a(Array)

      # binding.pry

      expect(@factory.create_vehicles(@registration_data_list, "Washington")).to be_a(Array)
      expect(@factory.create_vehicles(@registration_data_list, "Washington")).to eq(@factory.vehicles_manufactured)
    end

    it 'can create vehicles from acquired vehicle registration list for NY' do
      #Look at NY data this time
      ny_registration_data_list = @dds.ny_vehicle_registrations
      expect(ny_registration_data_list.size).to be_a(Integer)   #Like in other spec file.  Don't know why it wouldn't be an integer...
      expect(ny_registration_data_list).to be_a(Array)

      ny_vehicles = @factory.create_vehicles(ny_registration_data_list, "New York")
      binding.pry

      #FIX THIS - SYNTAX ERROR
      #This should just be 'ny_vehicles' I think
      #How did I mess this up before?
      #DO THIS
      #DO THIS

      expect(ny_vehicles, "New York").to be_a(Array)
      expect(ny_vehicles, "New York").to eq(@factory.vehicles_manufactured)
    end

  end

end
