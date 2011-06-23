module ApplicationHelper
  def params_text_field_tag(name, options={})
    text_field_tag name, params.value_from_nested_key(name), options
  end

  def select_options_tag(name, list, options={})
    list = list.map{|x| x.is_a?(Array) ? [x[0],h(x[1])] : h(x) } # stringify values from lists
    selected = h(options[:value] || params.value_from_nested_key(name))
    select_tag(name, options_for_select(list,selected), options.except(:value))
  end

end
