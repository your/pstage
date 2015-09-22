class OfficesController < ApplicationController

  def show
    @office = Office.find_by_partner_id(params[:id])
    respond_to do |format|
      format.html do
        redirect_to '/'
      end
      format.json { render :json => @office.as_json(:only => [:address, :additional]) }
    end
  end
  
=begin  
  def index
    @offices = Office.all.order('partner_id asc')
  end
  
  def show
    if has_partner
      @partner = Partner.find_by_id(params[:partner])
      @office = Office.find_by_id(params[:id])
    end
  end
  
  def new
    if has_partner
      @partner = Partner.find_by_id(params[:partner])
      @office = Office.new
    end
  end

  def create
    @office = Office.new(office_params)
    @partner = Partner.find_by_id(@office.partner_id)
    if @office.save
      flash[:success] = "[info] Sede aggiunta con successo."
      redirect_to partner_path(id: @office.partner_id, office: @office.id)
    else
      flash[:danger] = "[info] Impossibile aggiungere nuova sede!"
      render :action => "new"
    end
  end
  
  def edit
    if has_partner
      @partner = Partner.find_by_id(params[:partner])
      @office = Office.find_by_id(params[:id])
    end
  end

  def update
    @office = Office.find_by_id(params[:id])
    @partner = Partner.find_by_id(@office.partner_id)
    if @office.update_attributes(office_params)
      flash[:success] = "[info] Sede aggiornata con successo."
      redirect_to partner_path(id: @office.partner_id, office: @office.id)
    else
      flash[:danger] = "[info] Si è verificato un errore durante l'aggiornamento!"
      render 'edit'
    end
  end

  def destroy
    @office = Office.where(id: params[:office], partner_id: params[:partner]).first
    if @office.destroy
      flash[:success] = "[info] Sede eliminata con successo."
    else
      flash[:success] = "[info] Si è verificato un errore durante l'eliminazione!"
    end
    redirect_to partner_path(id: @office.partner_id, office: @office.id)
    #flash[:success] = "[info] Sede rimossa con successo!"
    #redirect_to :action => :index
  end
  
  private

  def has_partner
    if params[:partner].nil?
      flash[:danger] = "[info] E' necessario selezionare un partner prima di aggiungere una sede!"
      redirect_to partners_path
      return false
    end
    return true
  end
  
  def office_params
    params.require(:office).permit(:partner_id, :address, :latitude, :longitude, :additional)
  end
  
=end
end