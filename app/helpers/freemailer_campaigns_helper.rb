module FreemailerCampaignsHelper
  # Create a link with +title+ (for campaign) that will open a Modalbox with that campaigns statuses (paginated, of course).
  def campaign_statuses(title, freemailer_campaign)
    link_to_function(title, "Modalbox.show('#{freemailer_campaign_statuses_path(freemailer_campaign)}',{title: 'Mailing Statuses for  \"#{freemailer_campaign.title}\"', width: '450'})")
  end
  
  # Calculate a minimum size to display the entire contents of a body of text in a text_area_tag.
  #
  # For example, given the following
  #   str = "This is a test\n\nBacon!\n\nChunky Bacon."
  # when we call <tt>size_for_text_area(str,6) it would return <tt>"6x6"</tt>. 
  # The first +6+ is because we said there were 6 columns. The second +6+ is because "Chunky" takes two rows, an empty space takes one, "Chunky Bacon." takes two, totalling four, plus two for good measure.
  def size_for_text_area_tag(string, cols = 40)
    lines = string.split("\n")
    rows = lines.map(&:length).inject(0)  do |sum,len| 
      sum + if len/cols > 0 
              len/cols
            else
              1
            end
    end
    "#{cols}x#{rows+2}"
  end
end

# A link rendered for will_paginate to be used on a freemailer campaign. This class lets links produced open additional Modalboxes and not replace the whole page with a partial
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
      new_page=old_page.gsub(/(\\d+)$/,#{page});
    }
  EOS
  puts "#{page}: #{onclick}"
  <<-EOS
      <a onclick="#{onclick}; Modalbox.show(new_page,{title: Modalbox.options.title, width: '450'});" href="#">#{text}</a>
    EOS
  end

  def page_span(page, text, attributes = {})
    @template.content_tag(:span, text, attributes)
  end
     
end