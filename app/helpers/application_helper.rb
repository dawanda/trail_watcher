module ApplicationHelper
  def params_text_field_tag(name)
    text_field_tag name, params[name]
  end
end
