require 'spec_helper'
require './lib/registrant.rb'       #May move this to helper file later...
require './lib/vehicle_factory.rb' #Again, this too?
require 'pry'

RSpec.describe VehicleFactory do
  before(:each) do
    @factory = VehicleFactory.new()


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

      # expect(@facility_1).to be_an_instance_of(Facility)
      # expect(@facility_1.name).to eq('DMV Tremont Branch')
      # expect(@facility_1.address).to eq('2855 Tremont Place Suite 118 Denver CO 80205')
      # expect(@facility_1.phone).to eq('(720) 865-4600')
      # expect(@facility_1.services).to eq([])
    end
  end

end
