class Admin::ResourcesController < Admin::BaseController
  # GET /admin/resources
  # GET /admin/resources.json
  def index
    @resources = Imodec::Resource.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @resources }
    end
  end

  # GET /admin/resources/1
  # GET /admin/resources/1.json
  def show
    @admin_resource = Imodec::Resource.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @admin_resource }
    end
  end

  # GET /admin/resources/new
  # GET /admin/resources/new.json
  def new
    @resource = Imodec::Resource.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @resource }
    end
  end

  # GET /admin/resources/1/edit
  def edit
    @admin_resource = Imodec::Resource.find(params[:id])
  end

  # POST /admin/resources
  # POST /admin/resources.json
  def create
    @resource = Imodec::Resource.new(params[:imodec_resource])

    respond_to do |format|
      if @resource.save
        format.html { redirect_to admin_resource_url(@resource), notice: 'Resource was successfully created.' }
        format.json { render json: @resource, status: :created, location: @resource }
      else
        format.html { render action: "new" }
        format.json { render json: @@resource.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /admin/resources/1
  # PUT /admin/resources/1.json
  def update
    @admin_resource = Imodec::Resource.find(params[:id])

    respond_to do |format|
      if @admin_resource.update_attributes(params[:Imodec_resource])
        format.html { redirect_to @admin_resource, notice: 'Resource was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @admin_resource.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/resources/1
  # DELETE /admin/resources/1.json
  def destroy
    @admin_resource = Imodec::Resource.find(params[:id])
    @admin_resource.destroy

    respond_to do |format|
      format.html { redirect_to admin_resources_url }
      format.json { head :no_content }
    end
  end
end
