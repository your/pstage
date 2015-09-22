class PartnersController < ApplicationController
  
  def show
    @partner = Partner.find_by_id(params[:id])
    respond_to do |format|
      format.html do
        redirect_to '/'
      end
      format.json { render :json => @partner.as_json(:only => [:name, :note, :vat, :activities, :website, :active]) }
    end
  end
  
=begin
  def index
    flash[:order_by] = params[:order_by] if !params[:order_by].nil?
    if flash[:order_by].nil?
      @partners = Partner.all.order('name asc')
    else
      query_str = "#{flash[:order_by]} asc"
      @partners = Partner.all.order(query_str)
    end
  end
  
  def show
    @partner = Partner.find_by_id(params[:id])
    #get_partnership
    #get_office
    @offices = Office.where(partner_id: @partner.id).all
    if params[:office].nil?
      @office = @offices.size > 0 ? @offices.first : nil
    else
      @office = Office.find_by_id(params[:office])
      if @office.nil?
        redirect_to @partner
      end
    end
    if @office.nil?
      @partnership = nil
    else
      @partnership = Partnership.where(partner_id: @partner.id, office_id: @office.id).first
    end
  end
  
  def new
    @partner = Partner.new
  end

  def create
    @partner = Partner.new(partner_params)
    if @partner.save
      flash[:success] = "[info] Partner '#{@partner.name}' aggiunto con successo."
      redirect_to @partner
      #redirect_to :action => :index
    else
      flash[:danger] = "[info] Impossibile aggiungere nuovo Partner!"
      render :action => "new"
    end
  end
  
  def edit
    @partner = Partner.find(params[:id])
  end

  def update
    @partner = Partner.find(params[:id])
    if @partner.update_attributes(partner_params)
      flash[:success] = "[info] Partner aggiornato con successo."
      redirect_to @partner
    else
      flash[:danger] = "[info] Si è verificato un errore durante l'aggiornamento!"
      render 'edit'
    end
  end

  def destroy
    @partner = Partner.find(params[:id])
    @partner.partnerships.destroy_all
    @partner.offices.destroy_all
    @partner.destroy
    flash[:success] = "[info] Partner rimosso con successo!"
    redirect_to :action => :index
  end
  
  
  def get_office
    @office = Office.find_by_partner_id(@partner.id)
  end
  
  def get_partnership
    @partnership = Partnership.find_by_partner_id(@partner.id)
  end
  
  private

  def partner_params
    params.require(:partner).permit(:name, :vat, :website, :active, :type)
  end
  
    def format_date_time
      datetime = params[:datetime]
      params[:datetime] = DateTime.strptime(datetime,
pref_date_time_format).strftime('%d/%m/%Y')
    end
  
=end
end
