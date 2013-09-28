#encoding:utf-8
require 'csv'
class Admin::CardsController < Admin::BaseController
  include Admin::CardsHelper
  # GET /admin/cards
  # GET /admin/cards.json
  def index
    @labels = Ecstore::Label.all

    sale_status = params[:sold] == "0" ? false : true
    key = params[:search][:key] if params[:search]

    @cards = Ecstore::Card.order("created_at desc")

    if params[:sold].present?
        @cards = @cards.where(:sale_status=>sale_status)
    end

    if key.present?
        @cards = @cards.where("no like :key",:key=>"%#{key}%")
    end


    @cards = @cards.paginate(:page=>params[:page],:per_page=>10)
    @cards_total = Ecstore::Card.count



  end

  def show
    @card = Ecstore::Card.find(params[:id])
  end

  # GET /admin/cards/new
  # GET /admin/cards/new.json
  # def new
  #   @card = Ecstore::Card.new

  #   respond_to do |format|
  #     format.html # new.html.erb
  #     format.json { render json: @card }
  #   end
  # end

  # GET /admin/cards/1/edit
  def edit
    @card = Ecstore::Card.find(params[:id])
  end

  # POST /admin/cards
  # POST /admin/cards.json
  # def create
  #   @card = Ecstore::Card.new(params[:card])

  #   respond_to do |format|
  #     if @card.save
  #       format.html { redirect_to @card, notice: 'Card was successfully created.' }
  #       format.json { render json: @card, status: :created, location: @card }
  #     else
  #       format.html { render action: "new" }
  #       format.json { render json: @card.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # PUT /admin/cards/1
  # PUT /admin/cards/1.json
  def update
    @card = Ecstore::Card.find(params[:id])

    respond_to do |format|
      if @card.update_attributes(params[:ecstore_card])

        message = params[:ecstore_card].collect  do |key,value|
            I18n.t("card.#{key}") + "=" + value
        end.join(",")

        Ecstore::CardLog.create(:member_id=>current_admin.account_id,
                                                :card_id=>@card.id,
                                                :message=>"更新卡信息,#{message}")

        format.html { redirect_to admin_cards_url, notice: 'Card was successfully updated.' }
        format.json { head :no_content }
        format.js
      
      else
        format.html { render action: "edit" }
        format.json { render json: @card.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/cards/1
  # DELETE /admin/cards/1.json
  # def destroy
  #   @card = Ecstore::Card.find(params[:id])
  #   @card.destroy

  #   respond_to do |format|
  #     format.html { redirect_to cards_url }
  #     format.json { head :no_content }
  #   end
  # end

  def buy
      @card = Ecstore::Card.find(params[:id])
  end


  def use
      @card = Ecstore::Card.find(params[:id])
  end

  def edit_user
      @card = Ecstore::Card.find(params[:id])
      @member_card = @card.member_card
      @buyer =  @member_card.buyer
  end
  
  def edit_pay
      @card = Ecstore::Card.find(params[:id])
      @user_card = @member_card = @card.member_card
  end

  def logs
      @card = Ecstore::Card.find(params[:id])
      @logs = @card.card_logs
  end

  def tag

      if params[:cards] == "all"
          @cards = Ecstore::Card.all
      else
          @cards = Ecstore::Card.find(params[:cards])
      end
      @cards.each do |card|
         Ecstore::Labelable.where(:label_id=>params[:label],
                                                   :labelable_id=>card.id,
                                                   :labelable_type=>"Ecstore::Card").first_or_create if card
      end

      render :text=>"ok"
  end

  def untag
      @card = Ecstore::Card.find(params[:id])
      @card.labelables.where(:label_id=>params[:label]).delete_all
      render "untag"
  end

  def cancel_order
     @card = Ecstore::Card.find(params[:id])
     @card.update_attribute :sale_status,false
     @member_card = @card.member_card
     Ecstore::CardLog.create(:member_id=>current_admin.account_id,
                                                :card_id=>@card.id,
                                                :message=>"取消卡订单,购买者=#{@member_card.buyer.login_name}")
     @member_card.destroy
     redirect_to admin_cards_url
  end


  def export
      @logger ||= Logger.new("log/card.log")
      
      if params[:card][:select_all].to_i > 0
         @cards = Ecstore::Card.all
      else
        @cards = Ecstore::Card.find(params[:selected_cards])
      end
      fields = ["卡号","面值","类型","销售状态","使用状态","卡状态","购卡人手机","用卡人手机","标签"]
      content =content_generate(fields,@cards)  #调用export方法
      send_data(content, :type => 'text/csv',:filename => "card_#{Time.now.strftime('%Y%m%d%H%M%S')}.csv")
  end

  def content_generate(fields,cards)
      output = CSV.generate do |csv|
        csv << fields
        cards.each do |card|
          content = []
          content.push card.no
          content.push card.value
          content.push card.card_type
          content.push card.status
          content.push card_sale_status_options[card.sale_status]
          content.push card_use_status_options[card.use_status]
          content.push sold_card_status_options[card.status]
          if card.member_card.nil?
              content.push ""
          else
              content.push card.member_card.buyer_tel
          end
          if card.member_card.nil?
              content.push ""
          else
              content.push card.member_card.user_tel
          end
          csv << content   # 将数据插入数组中
        end
      end
  end

  def import(options={:encoding=>"GB18030:UTF-8"})

        return redirect_to(admin_cards_url) unless params[:card]&&params[:card][:file] 

        file = params[:card][:file].tempfile
        csv_rows = CSV.read(file,options)
        @logger ||= Logger.new("log/card.log")
        @cols = Ecstore::CvsColumn.new
        first_row = 0
        @cols.parseModel(csv_rows[first_row])
        csv_rows.shift
        errors = {}
        begin
            Ecstore::Card.transaction do
                csv_rows.each_with_index do |row,idx|
                  index = @cols.index("卡号")
                  card_no = row[index]
                  @new_card = Ecstore::Card.find_by_no(row[index])
                  if !@new_card.nil? && @new_card.persisted?
                    @logger.error("[error]card no exist: ")
                    errors[idx+2] = "导入失败,卡号:#{card_no}已经存在."
                    next
                    # render :text=>"【异常】卡号已经存在"
                    # return
                  else
                    @card = Ecstore::Card.new
                  end
                  @card.no = row[index]
                  index = @cols.index("面值")
                  @card.value = row[index]
                  t_index = @cols.index("类型")
                  @card.card_type = row[t_index]
                  @card.status = "正常"
                  @card.sale_status = 0
                  @card.use_status = 0

                  if %(A B).include?(row[t_index])
                      if row[t_index] == "B"
                        index = @cols.index("激活码")
                        @card.password = row[index]
                        if row[index].blank?
                          errors[idx+2] = "导入失败,卡[#{card_no}]密码不能为空."
                          next
                        end
                      end
                  else
                        @logger.error("[error]card_type  can not be #{row[t_index]}")
                        errors[idx+2] = "导入失败,卡[#{card_no}]类型只能是A或者B,不能为其他值."
                        next
                  end
                  @card.save!
                  errors[idx+2] = "导入成功,卡号[#{card_no}]"
                end
            end
        rescue Exception => e
            @logger.error("[error]import card cvs error: "+e.to_s)
            errors[-9999] = "导入失败，请检查导入文件格式."
            # raise e
        end

        flash[:notice] = errors unless errors.empty?
        redirect_to admin_cards_path
  end


end
