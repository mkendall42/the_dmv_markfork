require 'spec_helper'
require './lib/registrant.rb'       #May move this to helper file later...

RSpec.describe Registrant do
    before(:each) do
        @registrant1 = Registrant.new("Bruce", 18, true, license_data_hash)
        @registrant2 = Registrant.new("Penny", 15, [false], license_data_hash)
    end

    describe '#initialize' do
        it 'can initialize' do
            default_hash = {:written => false, :license => false, :renewed => false}
            expect(@registrant).to be_a(Registrant)
            expect(@registrant.name).to eq("Bruce")
            expect(@registrant.age).to eq(18)
            expect(@registrant.permit).to eq(true)
            expect(@registrant.license_data).to eq(default_hash)

        end

        it 'can handle default paramters correctly on another registrant' do
            default_hash = {:written => false, :license => false, :renewed => false}
            expect(@registrant).to be_a(Registrant)
            expect(@registrant2.name).to eq("Penny")
            expect(@registrant2.age).to eq(15)
            expect(@registrant2.permit).to eq(false)
            expect(@registrant2.license_data).to eq(default_hash)
        end
    end
end
