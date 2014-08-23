class MancoController < ApplicationController

  layout "manco_template"
  def index

  end
  def show

  end

  def user
    if @user

    login_name=@user.login_name
    account_id=Ecstore::Account.find_by_sql(["select account_id from sdb_pam_account where login_name=?",login_name])
    @member=Ecstore::Member.find_by_sql(["select * from sdb_b2c_members where member_id=?",account_id])
   else
      # redirect_to "wlogin"
   end

  end

  def express
  end

  def black_index

  end

  def serach
    departure= params[:departure]
    arrival= params[:arrival]
    @un= Ecstore::Express.serachall(departure,arrival)
   end

  def follow
    render :layout => "manco_template"
  end
end
