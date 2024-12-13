#This clearly tracks a specific DMV facility's core information and serviced rendered (or perhaps I should say """"""services""""""")

class Facility
  attr_reader :name, :address, :phone, :services

  def initialize(facility_info)    #Accepts a hash as argument
    @name = facility_info[:name]
    @address = facility_info[:address]
    @phone = facility_info[:phone]
    @services = []
  end

  def add_service(service)
    @services << service
  end

  def include?(service_specified)
    #Check to see if this facility provides this service
    @services.find { |service| service == service_specified }
  end
end
