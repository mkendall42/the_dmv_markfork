#This clearly tracks a specific DMV facility's core information and serviced rendered (or perhaps I should say """"""services""""""")

class Facility
  attr_reader :name, :address, :phone, :services, :collected_fees, :registered_vehicles

  def initialize(facility_info)    #Accepts a hash as argument
    @name = facility_info[:name]
    @address = facility_info[:address]
    @phone = facility_info[:phone]
    @services = []
    #Added in iteration 2
    @collected_fees = 0
    @registered_vehicles = []
  end

  def add_service(service)
    @services << service
  end

  def include?(service_specified)
    #Check to see if this facility provides this service
    @services.find { |service| service == service_specified }
  end

  #Next: registered_vehicles()

end
