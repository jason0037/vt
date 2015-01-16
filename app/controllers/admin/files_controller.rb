class Admin::FilesController <  Admin::BaseController

  def index
    @files =  Ecstore::Files.paginate(:per_page=>20,:page=>params[:files],:order=>"updated_at desc")


  end


  def edit
    @files  = Ecstore::Files.find(params[:id])
    @action_url =  admin_files_path(@files)
    @method = :put
  end

  def new
    @file=Ecstore::Files.new
    @action_url =   admin_files_path
    @method = :post
  end

  def create
    uploaded_io = params[:file]
    if !uploaded_io.blank?
      extension = uploaded_io.original_filename.split('.')
      filename = "#{Time.now.strftime('%Y%m%d%H%M%S')}.#{extension[-1]}"
      filepath = "#{DATUM_PATH}/#{filename}"
      File.open(filepath, 'wb') do |file|
        file.write(uploaded_io.read)
      end
      params[:files].merge!(:url=>"/datum/#{filename}")
    end
    #  return render :text => params[:lab_device]
    @file=Ecstore::Files.new params[:files]
    if @file.save
      redirect_to admin_files_path
    else
      render :new
    end


end

  def show
    @files  = Ecstore::Files.find(params[:id])


  end


  def update
    @files  = Ecstore::Files.find(params[:id])
    if @files.update_attributes(params[:files])
      redirect_to admin_files_path
    else
      render :edit
    end
  end

  def destroy
    @files  = Ecstore::Files.find(params[:id])
    @files.destroy
    redirect_to admin_files_path
  end



end