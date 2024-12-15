require 'spec_helper'

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
  end
end
