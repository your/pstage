class RepresentativesController < ApplicationController
  
  def show
    @representative = Representative.find_by_partnership_id(params[:id])
    respond_to do |format|
      format.html do
        redirect_to '/'
      end
      format.json { render :json => @representative.as_json(:only => [:name, :tel, :fax, :email]) }
    end
  end
  
=begin
  def index
    @representatives = Representative.all.order('name asc')
  end
  
  def get_partner(representative)
    @partnership = Partnership.find_by_id(representative.partnership_id)
    @partner = Partner.find(@partnership.partner_id)
  end
  helper_method :get_partner
  
  def show
    if has_partner && has_office
      @partner = Partner.find(params[:partner])
      @representative = Representative.find(params[:id])
      @office = Office.find(params[:office])
    end
  end
  
  def new
    if has_partnership
      @partnership = Partnership.find_by_id(params[:partnership])
      @partner = Partner.find_by_id(@partnership.partner_id)
      @representative = Representative.new
      @office = Office.find_by_id(@partnership.office_id)
    end
  end

  def create
    @representative = Representative.new(representative_params)
    @partnership = Partnership.find_by_id(params[:representative]["partner_id"])
    @office = Office.find_by_id(params[:representative]["office_id"])
    if @representative.save
      @representative_contact = RepresentativeContact.new(representative_contact_params(@representative.id))
      if @representative_contact.save
        flash[:success] = "[info] Representative aggiunto con successo."
        redirect_to partner_path(id: @office.partner_id, office: @office.id)
      else
        @representative.destroy
        flash[:danger] = "[info] Impossibile aggiungere nuovo representative!"
        render :action => "new"
      end
    else
      flash[:danger] = "[info] Impossibile aggiungere nuovo representative!"
      render :action => "new"
    end
  end
  
  def edit
    if has_partner && has_office
      @partner = Partner.find(params[:partner])
      @representative = Representative.find_by_partner_id(@partner.id)
      @office = Office.find(params[:office])
    end
  end

  def update
    @representative = Representative.find(params[:id])
    @office = Office.find_by_id(@representative.office_id)
    if @representative.update_attributes(representative_params)
      flash[:success] = "[info] Representative aggiornata con successo."
      redirect_to partner_path(id: @office.partner_id, office: @office.id)
    else
      flash[:danger] = "[info] Si è verificato un errore durante l'aggiornamento!"
      render 'edit'
    end
  end
  
  private

  def has_partnership
    if params[:partnership].nil?
      flash[:danger] = "[info] E' necessario selezionare una partnership prima di aggiungere un representative!"
      redirect_to partners_path
      return false
    end
    return true
  end

  def has_partner
    if params[:partner].nil?
      flash[:danger] = "[info] E' necessario selezionare un partner prima di aggiungere un representative!"
      redirect_to partners_path
      return false
    end
    return true
  end
  
  def has_office
    if params[:office].nil?
      flash[:danger] = "[info] E' necessario aver impostato una sede prima di aggiungere un representative!"
      redirect_to partners_path
      return false
    end
    return true
  end
  
  def representative_params
    params.require(:representative).permit(:partnership_id, :name)
  end
  
  def representative_contact_params(representative_id)
    representative_contact = {
      tel: params[:representative][:tel],
      representative_id: representative_id
    }
  end
  
=end
end
