#This 'manufactures' cars.  Kinda a misnomer, since it just takes existing registration data from API
#(doesn't really build them), but I see why we could do this to 'help' the Vehicle class along.

class VehicleFactory
  attr_reader

  def initialize()
    #No explicit parameters for now (somewhat superfluous definition)
  end

end
