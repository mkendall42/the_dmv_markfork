#This 'manufactures' cars.  Kinda a misnomer, since it just takes existing registration data from API
#(doesn't really build them), but I see why we could do this to 'help' the Vehicle class along.

class VehicleFactory
  # attr_reader

  def initialize()
    #No explicit parameters for now (somewhat superfluous definition)
    #Later: keep track of vehicle list here for kicks?
  end

  def create_vehicles(vehicle_registration_list)
    #Should return array of created vehicles

    #Registration list is formatted as an array with each element a vehicle, which is a hash of many parameters
    vehicle_array = []
    
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
      vehicle_array << Vehicle.new(vehicle_data)
    end

    return vehicle_array
  end

end
