# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def resolve_right_column_partial
    right_column_hierarchy = [
      "#{controller.controller_path.gsub('/','_')}_#{params[:action]}",
      controller.controller_path.gsub('/','_'),
      'admin'
    ]
    right_column_hierarchy.each do |right_column_partial|
      file_to_test = "#{RAILS_ROOT}/app/views/shared/right_columns/_#{right_column_partial}.html.erb"
      logger.warn(file_to_test)
      if FileTest.exist?(file_to_test)
        return "shared/right_columns/#{right_column_partial}"
      end
    end
  end

  def display_tree_recursive(tree, parent_id)
    ret = "\n<ul id='node_#{parent_id}'>"
    tree.each do |node|
      if node.parent_id == parent_id
        ret += "\n\t<li>"
        ret += yield node
        ret += display_tree_recursive(tree, node.id) { |n| yield n } unless node.children.empty?
        ret += "\t</li>\n"
      end
    end
    ret += "</ul>\n"
  end

  def sorted_class(sortable_name,data_name,prefix="")
    if params[:sortasc] == "#{sortable_name}-#{data_name}"
      "#{prefix}asc"
    elsif params[:sortdesc] == "#{sortable_name}-#{data_name}"
      "#{prefix}desc"
    end
  end

  def create_compact_object_widget(object_type, object, action)
    widget = "<div>"
    indicator = "#{icon(object_type.to_sym)} #{object_type.pluralize} #{'(<span id="contact-' + object_type + '-count-'  + object.id.to_s + '">' + object.send(object_type.pluralize).count.to_s + '</span>)'}"
    widget += link_to_function(indicator,"Modalbox.show('#{url_for(:controller => '/admin/contact', :action => action, :id => object.id, :context => 'modalbox')}',{title: '#{object_type.titleize.pluralize} for #{h object.name_for_display}', width: '800'})")
    widget += "</div>"
  end

  #This is included in rails 2.3, remove after we switch over.
  def grouped_options_for_select(grouped_options, selected_key = nil, prompt = nil)
    body = ''
    body << content_tag(:option, prompt, :value => "") if prompt
    grouped_options = grouped_options.sort if grouped_options.is_a?(Hash)
    grouped_options.each do |group|
      body << content_tag(:optgroup, options_for_select(group[1], selected_key), :label => group[0])
    end
    body
  end

  def sanitized_url_params
    url_params = params
    url_params.delete('authenticity_token')
    url_params.delete('commit')
    url_params
  end

  def show_help_link(help_page = 'general', title = 'General Help')
    link_to_function(icon('help') + ' Help',"Modalbox.show('#{url_for(:controller=> '/help', :action => help_page)}',{title: '#{title}', width: '800'})")
  end

end
