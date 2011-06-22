module ApplicationHelper
  def params_text_field_tag(name, options={})
    text_field_tag name, params.value_from_nested_key(name), options
  end
end
