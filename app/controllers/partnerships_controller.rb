class PartnershipsController < ApplicationController
  def index
    @partnerships = Partnership.all.joins(:partner).joins(:office).joins(:representatives).select('partnerships.id AS id, partners.name AS partner_name, partners.activities AS activities, offices.address AS office_address, representatives.name AS representatives_name, partnerships.signing_date AS signing_date').order('partnerships.id DESC')
    @partnerships.each { |partnership|
      partnership.activities = partnership.activities.capitalize if !partnership.activities.nil?
      partnership.signing_date = partnership.signing_date.to_date.strftime('%d/%m/%Y') if !partnership.signing_date.nil?
    }
  end
  
  def show
    @partnership = Partnership.where(partner_id: params[:id]).first # skipping office_id matching, add it asap
    respond_to do |format|
      format.json { render :json => @partnership.as_json(:only => [:id, :partner_id, :office_id, :active, :signing_date]) }
    end
  end
  
  def rollback
    raise ActivePartnership::Rollback, "Rolling back!"
  end
  
  def create
    @partnership, new_partner, new_office, new_partnership, new_representative = nil
    
    new_partner             = create_partner
    new_office              = create_office(new_partner)
    if new_office.nil?
      rollback
    else
      new_partnership       = create_partnership(new_partner, new_office)
      if new_partnership.nil?
        rollback
      else
        new_representative  = create_representative(new_partnership)
        if new_representative.nil?
          rollback
        else
          @partnership = Partnership.where(id: new_partnership.id).joins(:partner).joins(:office).joins(:representatives).select('partnerships.id AS id, partners.name AS partner_name, offices.address AS office_address, representatives.name AS representatives_name, partnerships.signing_date AS signing_date').order('partnerships.id DESC')
        end
      end
    end
    
    if @partnership
      render json: @partnership
    else
      render json: @partnership.errors, status: :unprocessable_entity
    end
    
  end
  
  def update
    @partnership = Partnership.find(params[:id])
    if @partnership.update(partnership_params)
      render json: @partnership
    else
      render json: @partnership.errors, status: :unprocessable_entity
    end
  end
    
  ## Please note, this will NOT destroy the partner and the office(s).
  ## Representatives will, since are linked to the partnership.
    def destroy
      @partnership = Partnership.find(params[:id])
      @partnership.destroy
      head :no_content
    end
    
  private

  def create_partner
    partner = Partner.new
    partner.name = partnership_params[:partner_name]
    partner.active = true
    partner.save!
    partner
  end
  
  def create_office(partner)
    office = Office.new
    p office
    office.address = partnership_params[:office_address]
    office.partner_id = partner.id
    office.save!
    office
  end
  
  def create_partnership(partner, office)
    partnership = Partnership.new
    partnership.signing_date = Date.parse(partnership_params[:signing_date]).strftime('%d/%m/%Y')
    partnership.partner_id = partner.id
    partnership.office_id = office.id
    partnership.active = true
    partnership.save!
    partnership
  end
  
  def create_representative(partnership)
    representative = Representative.new
    representative.name = partnership_params[:representatives_name]
    representative.partnership_id = partnership.id
    representative.save!
    representative
  end
  
  
  def partnership_params
    params.require(:partnership).permit(:partner_name, :office_address, :representatives_name, :activities_descr, :signing_date)
  end
        
=begin
  def index
    flash[:order_by] = params[:order_by] if !params[:order_by].nil?
    if flash[:order_by].nil?
      @partnerships = Partnership.all.order('partner_id asc')
    else
      query_str = "#{flash[:order_by]} asc"
      @partnerships = Partnership.all.order(query_str)
    end
  end
  
  def make_map
    @map = GMaps.new(div: '#map', lat: @office.latitude, lng: @office.longitude)
    @map.addMarker(lat: @office.latitude,
                   lng: @office.longitude,
                   title: @partner.office_id,
                   infoWindow: {
                     content: '<p>HTML Content</p>'
                   })
  end
  
  def get_partner(partnership)
    @partner = Partner.find(partnership.partner_id)
  end
  helper_method :get_partner
  
  def show
    if has_partner && has_office
      @partner = Partner.find(params[:partner])
      @partnership = Partnership.find(params[:id])
      @office = Office.find(params[:office])
    end
  end
  
  def new
    if has_partner && has_office
      @partner = Partner.find(params[:partner])
      @partnership = Partnership.new
      @office = Office.find(params[:office])
    end
  end

  def create
    @partnership = Partnership.new(partnership_params)
    @office = Office.find_by_id(@partnership.office_id)
    @partner = Partner.find(@office.partner_id)
    if @partnership.save
      flash[:success] = "[info] Partnership aggiunta con successo."
      redirect_to partner_path(id: @office.partner_id, office: @office.id)
    else
      flash[:danger] = "[info] Impossibile aggiungere nuova partnership!"
      render :action => "new"
    end
  end
  
  def edit
    if has_partner && has_office
      @partner = Partner.find(params[:partner])
      @partnership = Partnership.find_by_partner_id(@partner.id)
      @office = Office.find(params[:office])
    end
  end

  def update
    @partnership = Partnership.find(params[:id])
    @office = Office.find_by_id(@partnership.office_id)
    if @partnership.update_attributes(partnership_params)
      flash[:success] = "[info] Partnership aggiornata con successo."
      redirect_to partner_path(id: @office.partner_id, office: @office.id)
    else
      flash[:danger] = "[info] Si è verificato un errore durante l'aggioroffice_idnto!"
      render 'edit'
    end
  end
  
  private

  def has_partner
    if params[:partner].nil?
      flash[:danger] = "[info] E' necessario selezionare un partner prima di aggiungere una partnership!"
      redirect_to partners_path
      return false
    end
    return true
  end
  
  def has_office
    if params[:office].nil?
      flash[:danger] = "[info] E' necessario aver impostato una sede prima di aggiungere una partnership!"
      redirect_to partners_path
      return false
    end
    return true
  end
  
  def partnership_params
    params.require(:partnership).permit(:partner_id, :office_id, :signing_date, :additional)
  end
=end  
end
