require 'spec_helper'
require './lib/registrant.rb'       #May move this to helper file later...
require 'pry'

RSpec.describe Facility do
  before(:each) do
    @facility_1 = Facility.new({name: 'DMV Tremont Branch', address: '2855 Tremont Place Suite 118 Denver CO 80205', phone: '(720) 865-4600'})
    @facility_2 = Facility.new({name: 'DMV Northeast Branch', address: '4685 Peoria Street Suite 101 Denver CO 80239', phone: '(720) 865-4600'})

    @cruz = Vehicle.new({vin: '123456789abcdefgh', year: 2012, make: 'Chevrolet', model: 'Cruz', engine: :ice})
    @bolt = Vehicle.new({vin: '987654321abcdefgh', year: 2019, make: 'Chevrolet', model: 'Bolt', engine: :ev})
    @camaro = Vehicle.new({vin: '1a2b3c4d5e6f', year: 1969, make: 'Chevrolet', model: 'Camaro', engine: :ice})

    @registrant_1 = Registrant.new("Bruce", 18, true)
    @registrant_2 = Registrant.new("Penny", 16)
    @registrant_3 = Registrant.new("Tucker", 15)
  end

  describe '#initialize' do
    it 'can initialize' do
      expect(@facility_1).to be_an_instance_of(Facility)
      expect(@facility_1.name).to eq('DMV Tremont Branch')
      expect(@facility_1.address).to eq('2855 Tremont Place Suite 118 Denver CO 80205')
      expect(@facility_1.phone).to eq('(720) 865-4600')
      expect(@facility_1.services).to eq([])
    end

    it 'starts with correct collected_fees and registered_vehicles' do
      #Added for iteration 2
      expect(@facility_1.collected_fees).to eq(0)
      expect(@facility_1.registered_vehicles).to eq([])
    end

    it 'can initialize with state specified' do
      expect(@facility_1.state).to eq(nil)

      facility_4 = Facility.new({name: 'DMV Made-up Branch', address: '3698 W. 44th Avenue Denver CO 80211', phone: '(720) 865-4600', state: "Wyoming"})

      expect(facility_4.state).to eq("Wyoming")
    end

    it 'can initialize with hours and potential holidays specified' do
      facility_5 = Facility.new({name: 'DMV Made-up Branch', address: '3698 W. 44th Avenue Denver CO 80211', phone: '(720) 865-4600', state: "Wyoming", hours: "M-F 9AM-5PM", holidays: "A few days listed here"})

      expect(facility_5.hours).to eq("M-F 9AM-5PM")
      expect(facility_5.holidays).to eq("A few days listed here")
    end

  end

  describe '#add service' do
    it 'can add available services' do
      expect(@facility_1.services).to eq([])
      @facility_1.add_service('New Drivers License')
      @facility_1.add_service('Renew Drivers License')
      @facility_1.add_service('Vehicle Registration')
      expect(@facility_1.services).to eq(['New Drivers License', 'Renew Drivers License', 'Vehicle Registration'])
    end
  end

  describe '#register_vehicle' do
    it 'can register vehicles' do
      @facility_1.add_service('Vehicle Registration')
      @facility_1.register_vehicle(@cruz)
      @facility_1.register_vehicle(@bolt)
      @facility_1.register_vehicle(@camaro)

      expect(@facility_1.registered_vehicles).to eq([@cruz, @bolt, @camaro])
    end

    it 'can only register a vehicle if that service is provided by facility' do
      @facility_1.add_service("New Drivers License")
      @facility_1.register_vehicle(@cruz)

      expect(@facility_1.registered_vehicles).to eq([])
    end

    it 'collects fee and assigns plate appropriately' do
      @facility_1.add_service('Vehicle Registration')

      @facility_1.register_vehicle(@cruz)
      @facility_1.register_vehicle(@bolt)
      @facility_1.register_vehicle(@camaro)

      #Oof, this is a lot, but needed to exahustively test possible cases:
      expect(@facility_1.collected_fees).to eq(325)
      expect(@facility_1.registered_vehicles[0].plate_type).to eq(:regular)
      expect(@facility_1.registered_vehicles[1].plate_type).to eq(:ev)
      expect(@facility_1.registered_vehicles[2].plate_type).to eq(:antique)
      expect(@facility_1.registered_vehicles[0].registration_date).to_not eq(nil)
      expect(@facility_1.registered_vehicles[1].registration_date).to_not eq(nil)
      expect(@facility_1.registered_vehicles[2].registration_date).to_not eq(nil)
    end

  end

  describe '#administer_written_test' do
    it 'can only administer written test if service provided by facility' do
      expect(@facility_1.administer_written_test(@registrant_1)).to eq(false)
      
      @facility_1.add_service("New Drivers License")

      expect(@facility_1.administer_written_test(@registrant_1)).to eq(true)
    end

    it 'cannot administer written test if registrant does not meet requirements' do
      @facility_1.add_service("New Drivers License")

      expect(@facility_1.administer_written_test(@registrant_2)).to eq(false)
      expect(@facility_1.administer_written_test(@registrant_3)).to eq(false)
    end

    it 'updates license information for registrants who can/do complete written exam' do
      @facility_1.add_service("New Drivers License")

      #Works immediately for registrant 1
      expect(@facility_1.administer_written_test(@registrant_1)).to eq(true)
      expect(@registrant_1.license_data[:written]).to eq(true)

      #Works for registrant 2 after they get their permit
      expect(@facility_1.administer_written_test(@registrant_2)).to eq(false)
      @registrant_2.earn_permit
      expect(@facility_1.administer_written_test(@registrant_2)).to eq(true)
      expect(@registrant_2.license_data[:written]).to eq(true)

      #Cannot work for registrant 3 (at least not until next year)
      expect(@facility_1.administer_written_test(@registrant_3)).to eq(false)
      @registrant_3.earn_permit
      expect(@facility_1.administer_written_test(@registrant_3)).to eq(false)
      expect(@registrant_3.license_data[:written]).to eq(false)
    end

  end

  describe '#administer_road_test' do
    it 'can only administer road test if service provided by facility' do
      expect(@facility_1.administer_road_test(@registrant_3)).to eq(false)
      #This part mimics interaction pattern, but isn't necessary since they can't take it regardless (and that has already been tested)
      @registrant_3.earn_permit()
      @facility_1.administer_written_test(@registrant_3)

      expect(@facility_1.administer_road_test(@registrant_3)).to eq(false)
      expect(@registrant_3.license_data[:license]).to eq(false)
    end

    it 'road test success only for valid registrant, and updates license_data appropriately' do
      #Remember that the written test must be successfully completed first...
      @facility_1.add_service("Road Test")
      @facility_1.add_service("New Drivers License")

      expect(@facility_1.administer_road_test(@registrant_1)).to eq(false)

      @facility_1.administer_written_test(@registrant_1)

      expect(@facility_1.administer_road_test(@registrant_1)).to eq(true)
      expect(@registrant_1.license_data[:license]).to eq(true)
    end
  end

  describe '#renew_drivers_license' do
    it 'can only renew license if service provided by facility' do
      expect(@facility_1.renew_drivers_license(@registrant_1)).to eq(false)

      @facility_1.add_service("Road Test")
      @facility_1.add_service("New Drivers License")
      @facility_1.add_service("Written Test")
      @facility_1.add_service("Renew License")

      expect(@facility_1.renew_drivers_license(@registrant_1)).to eq(false)

      #Registrant must already have a license to do this.
      #Bad practice to manually set that, so use methods how one would actually do it:
      @facility_1.administer_written_test(@registrant_1)
      @facility_1.administer_road_test(@registrant_1)

      expect(@facility_1.renew_drivers_license(@registrant_3)).to eq(false)
    end

    it 'properly sets all appropriate registrant license information' do
      @facility_1.add_service("Road Test")
      @facility_1.add_service("New Drivers License")
      @facility_1.add_service("Written Test")
      @facility_1.add_service("Renew License")

      @facility_1.administer_written_test(@registrant_1)
      @facility_1.administer_road_test(@registrant_1)
      @facility_1.renew_drivers_license(@registrant_1)

      max_upgrades_hash = {written: true, license: true, renewed: true}
      expect(@registrant_1.license_data).to eq(max_upgrades_hash)
    end
  end

end
