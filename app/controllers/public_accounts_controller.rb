class PublicAccountsController < ApplicationController
  #before_action :set_public_account, only: [:show, :edit, :update, :destroy]

  # GET /public_accounts
  # GET /public_accounts.json
  def index
    @public_accounts = Ecstore::PublicAccounts.all
  end

  # GET /public_accounts/1
  # GET /public_accounts/1.json
  def show
  end

  # GET /public_accounts/new
  def new
    @public_account = Ecstore::PublicAccounts.new
  end

  # GET /public_accounts/1/edit
  def edit
  end

  # POST /public_accounts
  # POST /public_accounts.json
  def create
    @public_account = Ecstore::PublicAccount.new(public_account_params)

    respond_to do |format|
      if @public_account.save
        format.html { redirect_to @public_account, notice: 'public_account was successfully created.' }
        format.json { render action: 'show', status: :created, location: @public_account }
      else
        format.html { render action: 'new' }
        format.json { render json: @public_account.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /public_accounts/1
  # PATCH/PUT /public_accounts/1.json
  def update
    respond_to do |format|
      if @public_account.update(public_account_params)
        format.html { redirect_to @public_account, notice: 'public_account was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @public_account.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /public_accounts/1
  # DELETE /public_accounts/1.json
  def destroy
    @public_account.destroy
    respond_to do |format|
      format.html { redirect_to public_accounts_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_public_account
      @public_account = Ecstore::PublicAccounts.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def public_account_params
      params[:public_account].permit(:name, :password)
    end
end