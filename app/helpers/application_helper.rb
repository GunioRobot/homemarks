module ApplicationHelper  
  
  include CacheMasters::UrlPaths
  
  
  def title(title)
    content_for(:title) { h(title) }
  end
  
  
  
  
  
  
  
  
  def make_msg(type,message)
    page.hide :loading
    page.<< "Element.addClassName('hud','#{type}');"
    page.replace_html :message_wrapper, "<span id='message' class='msg_#{type}'>#{message}</span>"
    page.delay(5) do 
      page.<< "Element.removeClassName('hud','#{type}');"
      page.visual_effect :fade, 'message'
    end
  end
  
  def complete_forgotpw_form(mood)
    page.complete_ajax_form(mood,'forgotpw_form')
    if mood=='good'
      page['forgotpw_email'].value = 'Reset password email sent.'
      page<< %| $('forgotpw_email').setStyle({backgroundColor:'#96ff1f'}) |
      page['forgotpw_submit'].disable
      page['forgotpw_cancel'].disable
    end
  end
  
  def redirect_function(location)
    %Q{window.location.href='#{location}'}
  end
  
  def redirect_function_url_for(location)
    %Q{window.location.href='#{url_for(location)}'}
  end
  
  
  
  def link_to_remote_for_column_delete(col)
    link_to_remote( content_tag('span', '', :class => 'ctl_close'),
                  { :confirm => 'Are you sure? Deleting a COLUMN will also delete all the boxes and bookmarks within it.',
                    :url => column_destroy_url(:id => col.id),
                    :before => 'this.blur(); globalLoadingBehavior()' })
  end
  
  def link_to_remote_for_column_add(col)
    link_to_remote( content_tag('span', '', :class => 'ctl_add'),
                  { :url => box_new_url(:id => col.id),
                    :before => 'this.blur(); globalLoadingBehavior()' })
  end
  
  def link_to_remote_for_box_actions(box, action_dir)
    span_class = 'box_action' if action_dir == 'down'
    span_class = 'box_action box_action_down' if action_dir == 'up'
    link_to_remote( content_tag('span', '', :id => "boxid_#{box.id}_action", :class => span_class),
                  { :url => {:controller => 'box', :action => "actions_#{action_dir}", :id => box.id, :collapsed => box.collapsed?},
                    :before => "this.blur(); globalLoadingBehavior(); loadLameActionSpan(#{box.id},'#{action_dir}')" },
                    :id => "boxid_#{box.id}_action_alink" )
  end
  
  def link_to_remote_for_box_title(box)
    link_to_remote( h(box.title),
                  { :url => box_collapse_url(:id => box.id), 
                    :before => "this.blur(); globalLoadingBehavior(); loadLameActionSpan(#{box.id},'up')" }, 
                    :id => "boxid_#{box.id}_title" )
  end
  
  def link_to_remote_for_box_delete(box)
    link_to_remote( content_tag('span', '', :class => 'box_delete'), 
                  { :confirm => 'Are you sure? Deleting a BOX will also delete all the bookmarks within it.',
                    :url => box_destroy_url(:id => box.id),
                    :before => 'this.blur(); globalLoadingBehavior()' } )
  end
  
  def link_to_remote_for_box_color_swatches(box,swatch)
    link_to_remote( content_tag('span', '', :class => "box_swatch swatch_#{swatch}"),
                    :url => change_color_url(:id => box.id, :color => swatch),
                    :before => "this.blur(); $('boxid_#{box.id}_style').classNames().set('box #{swatch}')" )
  end
  
  def link_to_remote_for_box_edit_links(box)
    link_to_remote( content_tag('span', '', :class => 'box_edit'),
                    :url => edit_links_url(:id => box.id),
                    :before => "this.blur(); setupModal(#{box.id})",
                    :loading => "Element.show('modal_progress')" )
  end
  
  def link_to_remote_for_bookmark_new(box)
    link_to_remote( image_tag('/stylesheets/images/modal/command_new-bookmark2.png', :alt => 'New Bookmark', :class => 'modal_command_new'),
                    :url => new_in_box_url(:id => box.id),
                    :before => 'this.blur()' )
  end
  
  def link_to_remote_for_actionarea_inbox
    link_to_remote( content_tag('span', '', :id => 'legend_inbox' ), 
                   {:url => show_inbox_url,
                    :condition => 'isActionAreaDisplayed(this)',
                    :before => "loadingActionArea(this)"},
                    :id => 'legend_inbox_link')
  end
  
  def link_to_remote_for_actionarea_trashbox
    link_to_remote( content_tag('span', '', :id => 'legend_trash' ), 
                   {:url => show_trashbox_url,
                    :condition => 'isActionAreaDisplayed(this)',
                    :before => "loadingActionArea(this)"},
                    :id => 'legend_trash_link')
  end
  
  def bookmark_list_item
    %q|<li id="<%= box_type %>bmark_<%= bmark.id %>" class="dragable_bmarks clearfix <%= box_type %>"><span class="bmrk_handle">&nbsp;</span><span class="boxlink"><a href="<%= h(bmark.url) %>"><%= h(bmark.name) %></a></span></li>|
  end
  
  def complete_action_area(box_list)
    page['fieldset_progress_wrap'].visual_effect :blind_up, { :duration => 0.35 }
    page[box_list].visual_effect :blind_down, { :duration => 0.35 }
  end
  
  def update_new_trashboxmark_ui_elements_and_message
    page.<< "$('trashcan').classNames().set('trash_full'); showOrHideEmptyTrashBox();"
    page.make_msg('good','Bookmark moved to trash.')
  end
  
  def remove_all_trashboxmark_ui_elements_and_message(trashempty)
    page.<< "$('trashcan').classNames().set('trash_empty'); showOrHideEmptyTrashBox();" if trashempty
    page.make_msg('good','Permanently deleted.')
  end
  
  def empty_trash_function
    remote_function( :url => empty_trash_url,
                     :confirm => 'Are you sure? This will permanently delete all bookmarks in your trash.' )
  end
  
  
  
  def create_box_sortables(user)
    user.columns.each do |col|
      page.create_box_sortables_code(user, col)
    end    
  end
  
  def create_bookmark_sortables(user)
    user.boxes.each do |box|
      page.create_bookmark_sortables_code(user, box)
    end
  end
  
  def create_column_sortable
    page.sortable :col_wrapper,
                  :handle => 'ctl_handle',
                  :tag => 'div',
                  :only => 'dragable_columns',
                  :containment => 'col_wrapper',
                  :constraint => false,
                  :dropOnEmpty => true,
                  :url => {:controller => 'column', :action => 'sort'},
                  :before => 'globalLoadingBehavior()',
                  :with => 'findSortedInfo(this)'
  end
  
  def create_box_sortables_code(user, col)
    page.sortable "col_#{col.id}",
                  :tag => 'div',
                  :only => 'dragable_boxes',
                  :hoverclass => 'column_hover',
                  :accept => 'dragable_boxes',
                  :handle => 'box_handle',
                  :containment => user.column_containment_array,
                  :constraint => false,
                  :dropOnEmpty => true,
                  :url => { :controller => 'box', :action => 'sort' },
                  :before => 'globalLoadingBehavior()',
                  :with => 'findDroppedBoxInfo(this)'
  end
  
  def create_bookmark_sortables_code(user, box)
    sortable_id = case box
                  when Box : "boxid_list_#{box.id}"
                  when Inbox : 'inbox_list'
                  when Trashbox : 'trashbox_list'
                  end
    page.sortable sortable_id,
                  :accept => 'dragable_bmarks',
                  :handle => 'bmrk_handle',
                  :containment => user.box_containment_array,
                  :constraint => false,
                  :dropOnEmpty => true,
                  :url => { :controller => 'bookmark', :action => 'sort' },
                  :before => 'globalLoadingBehavior()',
                  :with => 'findDroppedBookmarkInfo(this)'
  end
  
  def reorder_then_create_box_sortables(col,user)
    # Due to some bug, affected column needs to be first in the array before create sortable code fires.
    ucols = user.columns
    ucols.slice!(ucols.index(col))
    ucols.unshift(col).each do |sortcol|
      page.create_box_sortables_code(user, sortcol)
    end
  end
  
  
  
  def blind_box_parts(box, node, direction)
    case
      when direction == :up
        page["boxid_#{box.id}_#{node}"].visual_effect :blind_up, { :duration => 0.35, :queue => {:position => 'end', :scope => "boxid_#{box.id}"} }
      when direction == :down
        page["boxid_#{box.id}_#{node}"].visual_effect :blind_down, { :duration => 0.35, :queue => {:position => 'end', :scope => "boxid_#{box.id}"} }
    end
  end
  
  def blind_new_box(box)
    page["boxid_#{box.id}"].visual_effect :blind_down, { :duration => 0.35, :queue => {:position => 'end', :scope => "boxid_#{box.id}"} }
  end
  
  
  
  def render_bookmarklet
    js = render :partial => 'bookmarklet/bookmarklet'
    js.gsub!('<script>','')
    js.gsub!('</script>','')
    js.gsub!(/ {2,}/,'')
    js.gsub!(/\n/,'')
    js.gsub!(/ /,'%20')
    js
  end
  
  def render_bookmarklet_save_button
    js = render :partial => 'bookmarklet/add_button'
    js.gsub!('<script>','')
    js.gsub!('</script>','')
    js.gsub!(/ {2,}/,'')
    js.gsub!(/\n/,'')
    js
  end
  

  
  
end
