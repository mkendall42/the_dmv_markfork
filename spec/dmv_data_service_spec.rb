require 'spec_helper'
require 'pry'

RSpec.describe DmvDataService do
  before(:each) do
    @dds = DmvDataService.new
  end
  describe '#initialize' do
    it 'can initialize' do

      # binding.pry

      expect(@dds).to be_an_instance_of(DmvDataService)
    end
  end

  describe '#load_data' do
    it 'can load data from a given source' do
      source = 'https://data.colorado.gov/resource/dsw3-mrn4.json'
      data_response = @dds.load_data(source)
      expect(data_response).to be_an_instance_of(Array)
      expect(data_response.size).to be_an(Integer)
    end
  end

  describe '#wa_ev_registrations' do
    it 'can load washington ev registration data' do

      #Check out the dataset manually for now:
      # binding.pry
      #Returned data in @dds.wa_ev_registrations is an array of vehicles.
      #Each vehicle is a hash with many parameters, though there isn't much nesting.


      expect(@dds.wa_ev_registrations.size).to be_an(Integer)
    end
  end

  describe '#ny_vehicle_registrations' do
    it 'can load new york general vehicle regisration data' do
      expect(@dds.ny_vehicle_registrations.size).to be_an(Integer)

      #Let's take a look at it...
      # binding.pry

      expect(@dds.ny_vehicle_registrations).to be_an(Array)
    end
  end

  describe '#co_dmv_office_locations' do
    it 'can load colorado dmv office locations' do
      expect(@dds.co_dmv_office_locations.size).to be_an(Integer)
    end
  end

  describe '#ny_dmv_office_locations' do
    it 'can load new york dmv office locations' do
      expect(@dds.ny_dmv_office_locations.size).to be_an(Integer)
    end
  end

  describe '#mo_dmv_office_locations' do
    it 'can load missouri dmv office locations' do
      expect(@dds.mo_dmv_office_locations.size).to be_an(Integer)
    end
  end
end
