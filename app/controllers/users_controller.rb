class UsersController < ApplicationController
  
  helper SiteHelper
  filter_parameter_logging :password
  
  skip_before_filter  :login_required,     :only => [ :new, :create ]
  before_filter       :redirect_logged_in, :only => [ :new, :create ]
  
  # before_filter      :control_demo_user, :only => [ :forgot_password, :change_password, :edit, :delete, :restore_deleted ]
  # before_filter      :nil_demo_account,  :only => [ :signup, :login ]
  
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.create!(params[:user])
    self.current_user = @user
    head :ok
  end
  
  
  
  
  
  # def home
  #   @trashbox = @user.trashbox
  #   render :layout => 'application'
  # end
  # 
  # def change_password
  #   redirect_to myaccount_url if request.get?
  #   if request.post?
  #     @user.update_attributes! params[:user]
  #     send_account_changed_notification(@user)
  #     flash[:good] = 'Password changed.'
  #     render(:update) {|page| page.redirect_to(myhome_url)}
  #   end
  # rescue ActiveRecord::RecordInvalid
  #   render(:update) {|page| page.complete_ajax_form('bad','mypassword_form','mypassword_loading')}
  # end
  # 
  # def edit
  #   if request.post?
  #     send_account_changed_notification(@user, @user.email)
  #     send_account_changed_notification(@user, params[:user][:email])
  #     @user.email = params[:user][:email] ; @user.save!
  #     flash[:good] = 'Email address updated.'
  #     render(:update) {|page| page.redirect_to(myhome_url)}
  #   end
  # rescue ActiveRecord::RecordInvalid
  #   render(:update) {|page| page.complete_ajax_form('bad','myemail_form','myemail_loading')}
  # end
  # 
  # def delete
  #   redirect_to index_url if request.get?
  #   if request.post?
  #     token = @user.delete!
  #     UserNotify.deliver_pending_delete(@user, recover_url(:user_id => @user.id, :token => token), issues_form_url)
  #     logout
  #   end
  # end
  # 
  # def restore_deleted
  #   @user.deleted = false
  #   if @user.save
  #     flash[:good] = "Welcome back :)"
  #     redirect_to myhome_url
  #   else
  #     redirect_to issues_form_url
  #   end
  # end
  
  
  protected
  
  # def send_account_changed_notification(user, email=nil)
  #   UserNotify.deliver_change_account(user, issues_form_url, email)
  # end
  # 
  # # FIXME: Put in some admin namespace
  # def destroy(user)
  #   UserNotify.deliver_delete(user, issues_form_url)
  #   flash[:good] = "The account for #{user['login']} was successfully deleted."
  #   user.destroy()
  # end
  # 
  # def email_demo?
  #   params[:user][:email] == HmConfig.demo[:email]
  # end
  
  
  
end
