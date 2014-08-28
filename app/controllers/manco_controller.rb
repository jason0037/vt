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
       redirect_to '/wlogin?return_url=/manco/user'
   end

  end

  def express
  end

  def black_index

    # @good=Ecstore::Good.find_all_by_cat_id(576)
      @good=Ecstore::Good.paginate :page=>params[:page],
                                   :per_page => 1,
                                   :conditions => ["cat_id=576"]
  end

  def serach
    departure= params[:departure]
    arrival= params[:arrival]
    @un= Ecstore::Express.serachall(departure,arrival)
   end

  def follow

  end
  def new
    @good  =  Ecstore::Good.new

    @method = :post
  end
  def black_board

  end
  def blackbord_add
    @good  =  Ecstore::Good.new(params[:good])
       if @good.save
          redirect_to "/manco/blackbord"
       else
        render :new
      end


    end




end
