require 'spec_helper'
require './lib/registrant.rb'       #May move this to helper file later...

RSpec.describe Registrant do
    before(:each) do
        @registrant_1 = Registrant.new("Bruce", 18, true)
        @registrant_2 = Registrant.new("Penny", 15)
    end

    describe '#initialize' do
        #Note: permit?() method also tested here
        it 'can initialize' do
            default_hash = {:written => false, :license => false, :renewed => false}
            
            expect(@registrant_1).to be_a(Registrant)
            expect(@registrant_1.name).to eq("Bruce")
            expect(@registrant_1.age).to eq(18)
            expect(@registrant_1.permit?()).to eq(true)
            expect(@registrant_1.license_data).to eq(default_hash)

        end

        it 'can handle default paramters correctly on another registrant' do
            default_hash = {:written => false, :license => false, :renewed => false}
            
            expect(@registrant_2).to be_a(Registrant)
            expect(@registrant_2.name).to eq("Penny")
            expect(@registrant_2.age).to eq(15)
            expect(@registrant_2.permit?()).to eq(false)
            expect(@registrant_2.license_data).to eq(default_hash)
        end
    end

    describe 'other methods' do
        it 'can earn permit' do
            expect(@registrant_2.permit?()).to eq(false)

            @registrant_2.earn_permit()

            expect(@registrant_2.permit?()).to eq(true)
        end
    end
end
