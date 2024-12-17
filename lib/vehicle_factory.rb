#This 'manufactures' cars.  Kinda a misnomer, since it just takes existing registration data from API
#(doesn't really build them), but I see why we could do this to 'help' the Vehicle class along.

class VehicleFactory
  attr_reader :vehicles_manufactured

  def initialize()
    @vehicles_manufactured = []
  end

  def create_vehicles(vehicle_registration_list, state)
    #Different states produce different datasets, so need to switch based on this.

    vehicle_registration_list.each do |vehicle|
      if state == "Washington"
        vehicle_data = {
          vin: vehicle[:vin_1_10],
          make: vehicle[:make],
          model: vehicle[:model],
          year: vehicle[:model_year],
          #Assume the engine is always ev here in WA (though not generally true - happy path for now)
          engine: :ev,
          county: vehicle[:county]
        }
      elsif state == "New York"
        #Engine type isn't specified in dataset.  Let's not get too fancy here, so just provide three options: :ev, :ice, or :other
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
          model: "data not available",      #Not provided in NY dataset, hence this value given
          year: vehicle[:model_year],
          engine: engine_type,
          county: vehicle[:county].capitalize     #Be consistent between states
        }
      else
        puts "Error: state invalid / not recognized.  Cannot build vehicles from registry."
        return []                     #To be consistent with typical return type
      end

      @vehicles_manufactured << Vehicle.new(vehicle_data)
    end

    return @vehicles_manufactured
  end

end
