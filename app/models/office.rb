class Office < ActiveRecord::Base
  belongs_to :partner
  has_one :partnership, dependent: :destroy
  belongs_to :area_level3
  belongs_to :area_level1
  
  validates :partner_id, :address, presence: true
  
  geocoded_by :address
  
  reverse_geocoded_by :latitude, :longitude do |obj,results|
    
    
    @geocoded = false
    
    #print "#{obj.id} #{obj.address}.. #{@geocoded}... #{results.size}"
    
    
    if !obj.area_level3_id.nil? or obj.address.nil?
      #print "#{obj.area_level3_id} is of size #{obj.area_level3_id.size}..."
      next
    end
    
    results.each_with_index do |geo,i|
      
      #print 'trying...'

      break if @geocoded
      
      print "Geocoding #{obj.address}.. "
      
      # [{"street_number"=>"81"}, {"route"=>"Via Napoli"}, {"locality"=>"Bari"}, {"administrative_area_level3"=>"Bari"}, {"administrative_area_level2"=>"BA"}, {"administrative_area_level1"=>"Puglia"}, {"country"=>"IT"}, {"postal_code"=>"70123"}]
      # OR
      # [{"route"=>"Via Privata Ingegnere Paolo Foresio"}, {"administrative_area_level2"=>"VA"}, {"administrative_area_level1"=>"Lombardia"}, {"country"=>"IT"}, {"postal_code"=>"21040"}]
      fields_long           = geo.data["address_components"].map { |el| {el["types"][0] => el["long_name"] } }
      fields_short          = geo.data["address_components"].map { |el| {el["types"][0] => el["short_name"] } }      
            
            
      # Allowed countries so far: ["IT", "CH"]
      allowed_countries = ["IT", "CH"]
      
      country               = fields_short.select { |el| el["country"] }
      locality              = fields_long.select  { |el| el["locality"] }
      area_level3           = fields_short.select { |el| el["administrative_area_level_3"] }
      area_level2_long      = fields_long.select  { |el| el["administrative_area_level_2"] }
      area_level2           = fields_short.select { |el| el["administrative_area_level_2"] }
      area_level1           = fields_short.select { |el| el["administrative_area_level_1"] }
      route                 = fields_short.select { |el| el["route"] }
      street_number         = fields_short.select { |el| el["street_number"] }
      
      print "#{area_level1}"
      
      country_val           = country           == [] ? nil   : country[0].values[0].downcase
      locality_val          = locality          == [] ? nil   : locality[0].values[0].downcase
      area_level3_val       = area_level3       == [] ? nil   : area_level3[0].values[0].downcase
      area_level2_long_val  = area_level2_long  == [] ? nil   : area_level2_long[0].values[0].downcase
      area_level2_val       = area_level2       == [] ? nil   : area_level2[0].values[0].downcase
      area_level1_val       = area_level1       == [] ? nil   : area_level1[0].values[0].downcase
      route_val             = route             == [] ? nil   : route[0].values[0].downcase
      street_number_val     = street_number     == [] ? nil   : street_number[0].values[0].downcase
      
      # Operations to perform if and only if area_level_3_val is present:
      if !area_level3_val.nil?
        #print '0-'
        # monkey patching gmaps when answering with english names of some cities...
        area_level3_val =
          case area_level3_val
            when "milan" then "milano"
            when "rome" then "roma"
            when "naples" then "napoli"
            when "turin" then "torino"
            when "florence" then "firenze"
            when "venice" then "venezia"
            when "padua" then "padova"
            when "genoa" then "genova"
            when "syracuse" then "siracusa"
            when "trent" then "trento"
            else area_level3_val
          end
            
        # removing 'locality' if == to 'area_level_3'
        if !locality_val.nil?
          #print '0.1-'
          if locality_val == area_level3_val
            #print '0.2-'
            locality_val = nil
          end
        end
      else
        #print '1-'
        # No area_level_3_val? =(
        if !locality_val.nil?
          #print '1.1-'
          area_level3_val = locality_val
        else
          #print '1.2-'
          if !area_level2_val.nil?
            area_level3_val = area_level2_val
          else
            #print '1.3-'
            print ": ERROR! Can't find a way to substitute L3 (absent)"
            break # Premature break
          end
        end
      end
            
      # area_level_2_val is not required instead
      # area_level_1_val we assume is always sent by gmaps, instead... (shall we trust that? :O)
      
      # monkey patch for TARANTO
      area_level2_val = "ta" if !area_level2_val.nil? and area_level2_val == "taranto"
      
      # looking up db!
      area_level3_entry = AreaLevel3.find_by_name(area_level3_val)
      area_level1_entry = AreaLevel1.find_by_name(area_level1_val)
      
      print ": ERROR! Can't find #{area_level3_val} in db (L3)" if area_level3_entry.nil?
      print ": ERROR! Can't find #{area_level1_val} in db (L1)" if area_level1_entry.nil?
      
      # if records are found, let's proceed!
      if !area_level3_entry.nil?
        # are we obtaining coordinates within allowed known boundaries?
        if allowed_countries.map { |el| el.downcase }.include?(country_val)
          
          route_val       = route_val.titleize if !route_val.nil?
          locality_val    = locality_val.titleize if !locality_val.nil?
          area_level3_val = area_level3_val.titleize if !area_level3_val.nil?
          area_level2_val = area_level2_val.upcase if !area_level2_val.nil?
          
          obj.area_level3_id      = area_level3_entry.id
          obj.address             = [
                                      route_val,                  # Piazza Roma
                                      street_number_val,          # 10
                                      locality_val,               # Bari
                                      area_level3_val,            # Bari
                                      area_level2_val             # BA
                                    ]
                                    .delete_if { |el| el.nil? }.compact.join(', ')
                                  
          puts ": #{obj.address} - #{obj.latitude},#{obj.longitude}"
          @geocoded = true
          # work done! great! =)
        else
          obj.latitude  = nil
          obj.longitude = nil
          puts ": ERROR! #{country} not allowed"
          next if i+1 < results.size # try next guessing, if any.
        end
      else
        obj.latitude  = nil
        obj.longitude = nil
        puts ": ERROR! Couldn't find db entries either L3 and/or L1!"
        break # All attempts failed, go to next address.
      end
    end
  end
  
  after_initialize :new_office
  after_validation :geocode, :reverse_geocode
  
  def new_office
    @geocoded = false
  end

end
