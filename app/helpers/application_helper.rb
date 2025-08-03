module ApplicationHelper
  def source_code_links(sources: [])
    content_tag(:ul) do
      sources.map do |source|
        file_path = source[:path]
        line = source[:line] || 1
        description = source[:description]
        
        content_tag(:li) do
          if current = ActiveSupport::Editor.current
            link_to("#{description}", current.url_for(Rails.root.join(file_path), line))
          else
            content_tag(:code, file_path) + " - #{description}"
          end
        end
      end.join.html_safe
    end
  end
end
