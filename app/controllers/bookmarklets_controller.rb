class BookmarkletsController < ApplicationController

  skip_before_filter :login_required
  
  before_filter :redirect_if_no_referer,   :except => [ :create ]
  before_filter :redirect_if_self_referal, :only   => [ :new ]
  before_filter :find_user_by_uuid
  
  
  def new
    render :update do |page|
      page.alert 'Foo'
      # # Setting the styles of various DIVs in the bookmarklet code.
      # page.<< "Element.setStyle('modal_html_ap-wrapper',{position:'fixed',top:'0',left:'0',zIndex:'999999'});"
      # page.<< "Element.setStyle('modalmask',{position:'absolute',top:'0',left:'0',zIndex:'999998',width:'100%',height:'100%',textAlign:'center',backgroundColor:'#000',opacity:'0.9'});"
      # page.<< "$('modalmask').style.setProperty('-moz-opacity','0.9',null);"
      # page.<< "Element.setStyle('modal_progress',{position:'relative',width:'100px',height:'130px',margin:'0 auto',cursor:'pointer',backgroundImage:'url(#{HmConfig.app[:host]}javascripts/modal_assets/progress_invert.gif)'});"
      # page.<< "Event.observe('modal_progress','click', goHere, false);"
      # # Miscellaneous JavaScript calls to mimic a box's edit links modal.
      # page.remove :loadinghomemarks
      # page.<< "setupModal();"
      # page.show :modal_progress
      # page.replace_html 'modal_html_ap-wrapper', :partial => 'form'
      # page.<< "$('hm_bookmark_name').value = document.title;"
      # page.hide :modal_progress
      # page.visual_effect :slide_down, 'modal_html_rel-wrapper', :duration => 0.4, :queue => {:position => 'end', :scope => "boxid_bookmarklet"}
    end
  end
  
  def nonhtml
    # @bookmark_url = request.referer
    # @nonhtml = true
    # render :partial => 'form', :layout => 'nonhtml'
  end
  
  def create
    # setup_bookmark_url_instance_vars_and_box_object
    # @box.bookmarks.create :name => params[:bookmark][:name], :url => @bookmark_url
    # return redirect_to_bookmark_url if @nonhtml_url
    # render :update do |page|
    #   page.<< "destroyModalMask()"
    #   page.delay(1) {page.remove 'modal_html_ap-wrapper'}
    # end
  end
  

  
  
  
  protected
  
  def redirect_if_no_referer
    redirect_to root_url unless request.referer
  end
  
  def redirect_if_self_referal
    if request.referer.include?(HmConfig.app[:host])
      render(:update) { |page| page << "window.location='#{site_path('help',:anchor => 'homemarklet')}'"} 
    end
  end
  
  
  
  
  
  
  
  
  
  def redirect_to_bookmark_url
    render(:update) {|page| page.<< "#{redirect_function(@bookmark_url)}"}
  end
  
  def find_user_by_uuid
    @user = User.find_by_uuid(params[:uuid])
    if @user.blank?
      divid = case params[:action] ; when 'setup' : 'loadinghomemarks' ; when 'save' : 'savehomemarks_form_wrapper' ; when 'nonhtml' : '' ; end
      message = case params[:action] ; when 'setup' : 'Make bookmark modal failed.' ; when 'save' : 'Save bookmark failed.' ; when 'nonhtml' : 'Make non-HTML bookmark failed.' ; end
      return redirect_to(request.referer) if (params[:action]=='nonhtml')
      render :update do |page|
        page.replace_html divid, 'ERROR: Refreshing Page Now!'
        page.delay(1.5) { page.redirect_to request.referer }
      end
    end
  end
  
  def setup_bookmark_url_instance_vars_and_box_object
    @bookmark_url = (params[:bookmark][:url] == 'from_referer') ? request.referer : params[:bookmark][:url]
    @nonhtml_url = (params[:bookmark][:url] != 'from_referer') ? true : false
    @box = case params[:box][:id] ; when /\d+/ : @user.boxes.find($&) ; when 'inbox' : @user.inbox ; end
    find_box_type
  rescue
    redirect_to_bookmark_url
  end
  
  def find_box_type
    @box_type = case @box ; when Box : 'box' ; when Inbox : 'inbox' ; end
  end
  
  
  
end
