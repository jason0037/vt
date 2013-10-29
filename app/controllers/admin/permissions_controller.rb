#encoding:utf-8
class Admin::PermissionsController < Admin::BaseController
  def index
    @managers = Ecstore::Manager.all
  end

  def new
  end

  def update
   
    manager_id = params[:id]

    @permission = Imodec::Permission.where(:manager_id=>manager_id).first
    if @permission
      @permission.update_attributes(:rights=>params[:permission].to_json)
    else
      Imodec::Permission.create(:manager_id=>manager_id,:rights=>params[:permission].to_json)
    end
    
    redirect_to edit_admin_permission_path(params[:id]),:notice=>'权限保存成功!'
  end

  def edit
    @manager = Ecstore::Manager.find(params[:id])
    @resources = Imodec::Resource.where(:parent_id=>nil)
  end
end
