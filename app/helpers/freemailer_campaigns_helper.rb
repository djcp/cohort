module FreemailerCampaignsHelper
end

class StatusPaginationModalSwitchRenderer < WillPaginate::LinkRenderer
  def to_html
    links = @options[:page_links] ? windowed_links : []

    links.unshift(page_link_or_span(@collection.previous_page, 'previous', @options[:previous_label]))
    links.push(page_link_or_span(@collection.next_page, 'next', @options[:next_label]))

    html = links.join(@options[:separator])
  end
  
protected

  def windowed_links
    visible_page_numbers.map { |n| page_link_or_span(n, (n == current_page ? 'current' : nil)) }
  end

  def page_link_or_span(page, span_class, text = nil)
    text ||= page.to_s
    if page && page != current_page
      page_link(page, text, :class => span_class)
    else
      page_span(page, text, :class => span_class)
    end
  end

  def page_link(page, text, attributes = {})
    onclick = <<-EOS
    var old_page=Modalbox.content;
    var new_page;
    if(old_page.endsWith('statuses')){
      new_page=old_page+'?page='+#{page};
    }else{
      new_page=old_page.gsub(/(\d+)$/,#{page});
    }
  EOS
 
  <<-EOS
      <a onclick="#{onclick}; Modalbox.show(new_page,{title: Modalbox.title, width: '450'});" href="#">#{text}</a>
    EOS
  end

  def page_span(page, text, attributes = {})
    @template.content_tag(:span, text, attributes)
  end
     
end