# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

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

end
