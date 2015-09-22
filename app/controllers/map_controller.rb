require 'cgi'

class MapController < ApplicationController
  
  helper_method :get_city, :get_name, :get_type, :results, :get_lat, :get_lng, :get_zoom, :get_highlight, :get_sel_address
  
  def index
    
    if params[:name] == "" or params[:city] == ""
      new_params = params.map { |param| param }.keep_if { |param| param[1] != "" }.to_h
      redirect_to map_index_path(new_params)
    else
    
      capitalize_params
      unescape_params
    
      @offices = Office.where.not(latitude: nil, longitude: nil, area_level3_id: nil)
      
      @offices = @offices.where("address LIKE ?", "%, #{params[:city]}%")
    
      #if !params[:city].nil?
      #  found_city = AreaLevel3.find_by_name(params[:city].downcase)
      #  if !found_city.nil?
         # @offices = @offices.where(area_level3_id: found_city.id)
      #  else
      #    parameter_not_found(:city)
      #  end
      #end
    
      @offices = @offices.joins(:partner)
    
      if !params[:name].nil?
        @offices = @offices.where("partners.name LIKE ?", "%#{params[:name].upcase}%")
      end
      
      if !params[:type].nil?
        selected_types = params[:type].split(' ')
        #@offices = @offices.where("partners.p_type LIKE ?", "%#{params[:type].upcase}%")
        @offices = @offices.where(
                            [ selected_types.map { |m| "partners.p_type = ?" }.join(" OR ") ] +
                            (selected_types.map { |m| "#{m.upcase}" })
                          )
      end
      
      @offices = @offices.order('partners.name asc')
      
    end
      
    #if !params[:city].nil?
    #  found_city = AreaLevel3.find_by_name(params[:city])
    #  if !found_city.nil?
    #    if !params[:name].nil?
    #      @offices = Office.where.not(latitude: nil, longitude: nil).where(area_level3_id: found_city.id).joins(:partner).where("partners.name LIKE ?", "%#{params[:name]}%")       
    #    else
    #      @offices = Office.where.not(latitude: nil, longitude: nil).where(area_level3_id: found_city.id).joins(:partner)
    #    end
    #  else
    #    parameter_not_found(:city)
    #    get_all_offices
    #  end
    #else
    #  if !params[:name].nil?
    #    @offices = Office.where.not(latitude: nil, longitude: nil).joins(:partner).where("partners.name LIKE ?", "%#{params[:name]}%")       
    #  else
    #    parameter_not_found(:name)
    #    get_all_offices
    #  end
    #end
    

  end
  
  def get_city
    params[:city]
  end
  
  def get_name
    params[:name]
  end
  
  def get_types
    p_types = ['SPA', 'SRL', 'SNC']
    p_types.each_with_index.map {|name, index| [name, index]}
  end
  
  def get_type
    if params[:type].nil?
      params[:type]
    else
      params[:type].upcase
    end
  end
  
  def get_lat
    params[:lar]
  end
  
  def get_lng
    params[:lng]
  end
  
  def get_zoom
    params[:zoom]
  end
  
  def get_highlight
    params[:highlight]
  end
  
  def get_sel_address
    @office = @offices.find_by_id(params[:highlight])
    p @office
  end
  
  private
  
  def results
    @offices.count
  end
  
  def capitalize_params
    params.values.each_with_index { |p_v,i| params[params.keys[i]] = p_v.capitalize }
  end
  
  def unescape_params
    params.values.each_with_index { |p_v,i| params[params.keys[i]] = CGI.unescape(p_v) }
  end
  
  def parameter_not_found(param_name)
    flash[:danger] = "[info] Impossibile trovare corrispondenza con \"#{params[param_name]}\"!"
    remove_param_and_redirect(param_name)
  end
  
  def remove_param_and_redirect(param_name)
    new_params = clean_params_from(param_name)
    p new_params
    redirect_to map_index_path(new_params)
  end
  
  def clean_params_from(param)
    params.except(:controller, :action, param)
  end
end