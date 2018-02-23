module ApplicationHelper

  def custom_link(image, url)
    link_to image_tag(image), url, target: "_top"
  end

end
