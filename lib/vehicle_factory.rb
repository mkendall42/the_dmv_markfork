#This 'manufactures' cars.  Kinda a misnomer, since it just takes existing registration data from API
#(doesn't really build them), but I see why we could do this to 'help' the Vehicle class along.

class VehicleFactory
  attr_reader :vehicles_manufactured

  def initialize()
    #No explicit parameters for now (somewhat superfluous definition)
    #Later: keep track of vehicle list here for kicks?
    @vehicles_manufactured = []       #Keeps track of vehicles 'built' at this factory
  end

  def create_vehicles(vehicle_registration_list, state)
    #Should return array of created vehicles.
    #Different states produce different datasets, so need to switch based on this.

    #Registration list is formatted as an array with each element a vehicle, which is a hash of many parameters
    @vehicles_manufactured = []
    
    vehicle_registration_list.each do |vehicle|
      #Build a hash of relevant parameters (vin, make, model, year, engine)
      #Technically this hash is not ordered correctly, but shouldn't matter for a hash (double-checking)
      
      if state == "Washington"
        vehicle_data = {
          vin: vehicle[:vin_1_10],
          make: vehicle[:make],
          model: vehicle[:model],
          year: vehicle[:model_year],
          #Assume the engine is always ev here (though not generally true - happy path for now)
          engine: :ev,
          county: vehicle[:county]
        }
      elsif state == "New York"
        #Important note: there are a lot of 'vehicles' in NY registry that aren't the usual car/truck/similar, such as boats, snowmobiles, etc
        #which have deviating keys/values (for instance, no make).
        #For now, I'm going to just look at 'regular' vehicles to keep it a little simpler 
        #Later, I can maybe treat these all the same, but really the Vehicle class would have to be significantly expanded to handle this (and not clear for what purpose given the other code / scope of project)

        #Also, engine type isn't specified.  Let's not get too fancy here, so just provide three options:
        #Either :ev, :ice, or :other
        case vehicle[:fuel_type]
        when "ELECTRIC"
          engine_type = :ev
        when "GAS" || "DIESEL" || "PROPANE" || "FLEX"      #There are several fossil-fuel types...these are the only ones I'm pretty confident about
          engine_type = :ice
        else
          engine_type = :other
        end

        vehicle_data = {
          vin: vehicle[:vin],
          make: vehicle[:make],
          model: vehicle[:make],      #This one is pretty arbitrary, so just repeat 'make' for now (no actual 'model' value provided in the dataset!)
          year: vehicle[:model_year],
          engine: engine_type,
          county: vehicle[:county]
        }
      else
        puts "Error: state invalid / not recognized.  Cannot build vehicles from registry."
        return []                     #To be consistent with typical return type
      end

      #'Build' the vehicle:
      @vehicles_manufactured << Vehicle.new(vehicle_data)
    end

    return @vehicles_manufactured
  end

end
