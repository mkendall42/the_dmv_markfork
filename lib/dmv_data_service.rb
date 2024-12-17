require 'faraday'
require 'json'

#NOTE: I see that for the vehicle data loading, it only pulls 1000 vehicles for both WA and NY.  No way that is coincidence...where is the '1000' constraint present?

class DmvDataService
  def load_data(source)
    response = Faraday.get(source)
    JSON.parse(response.body, symbolize_names: true)
  end

  def wa_ev_registrations
    @wa_ev_registrations ||= load_data('https://data.wa.gov/resource/rpr4-cgyd.json')
  end

  def ny_vehicle_registrations
    #Iteration 4 - based on dataset URL provided.  Should have same structure as other entries:
    @ny_vehicle_registrations ||= load_data('https://data.ny.gov/resource/w4pv-hbkt.json')
  end

  def co_dmv_office_locations
    @co_dmv_office_locations ||= load_data('https://data.colorado.gov/resource/dsw3-mrn4.json')
  end

  def ny_dmv_office_locations
    @ny_dmv_office_locations ||= load_data('https://data.ny.gov/resource/9upz-c7xg.json')
  end

  def mo_dmv_office_locations
    @mo_dmv_office_locations ||= load_data('https://data.mo.gov/resource/835g-7keg.json')
  end
end
