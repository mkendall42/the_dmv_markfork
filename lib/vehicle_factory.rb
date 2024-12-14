#This 'manufactures' cars.  Kinda a misnomer, since it just takes existing registration data from API
#(doesn't really build them), but I see why we could do this to 'help' the Vehicle class along.

class VehicleFactory
  attr_reader :vehicles_manufactured

  def initialize()
    #No explicit parameters for now (somewhat superfluous definition)
    #Later: keep track of vehicle list here for kicks?
    @vehicles_manufactured = []       #Keeps track of vehicles 'built' at this factory
  end

  def create_vehicles(vehicle_registration_list)
    #Should return array of created vehicles

    #Registration list is formatted as an array with each element a vehicle, which is a hash of many parameters
    @vehicles_manufactured = []
    
    vehicle_registration_list.each do |vehicle|
      #Build a hash of relevant parameters (vin, make, model, year, engine)
      #Technically this hash is not ordered correctly, but shouldn't matter for a hash (double-checking)
      vehicle_data = {
        vin: vehicle[:vin_1_10],
        make: vehicle[:make],
        model: vehicle[:model],
        year: vehicle[:model_year],
        #Assume the engine is always ev here (though not generally true - happy path for now)
        engine: :ev
      }

      #'Build' the vehicle:
      @vehicles_manufactured << Vehicle.new(vehicle_data)
    end

    return @vehicles_manufactured
  end

end
