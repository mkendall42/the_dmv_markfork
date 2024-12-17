require 'spec_helper'

RSpec.describe VehicleFactory do
  before(:each) do
    @factory = VehicleFactory.new()
    @dds = DmvDataService.new()
    @registration_data_list = @dds.wa_ev_registrations
  end

  describe '#initialize' do
    it 'can initialize' do
      expect(@factory).to be_a(VehicleFactory)
      expect(@factory.vehicles_manufactured).to eq([])
    end
  end

  describe '#create_vehicles()' do
    it 'can create vehicles from acquired vehicle registration list for WA' do
      expect(@registration_data_list.size).to be_a(Integer)   #Like in other spec file.  Don't know why it wouldn't be an integer...
      expect(@registration_data_list).to be_a(Array)

      expect(@factory.create_vehicles(@registration_data_list, "Washington")).to be_a(Array)
      expect(@factory.create_vehicles(@registration_data_list, "Washington")).to eq(@factory.vehicles_manufactured)
    end

    it 'can create vehicles from acquired vehicle registration list for NY' do
      ny_registration_data_list = @dds.ny_vehicle_registrations
      expect(ny_registration_data_list.size).to be_a(Integer)
      expect(ny_registration_data_list).to be_a(Array)

      ny_vehicles = @factory.create_vehicles(ny_registration_data_list, "New York")

      expect(ny_vehicles).to be_a(Array)
      expect(ny_vehicles).to eq(@factory.vehicles_manufactured)
    end
  end

end
