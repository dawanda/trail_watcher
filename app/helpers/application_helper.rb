module ApplicationHelper
  def params_text_field_tag(name, options={})
    text_field_tag name, params.value_from_nested_key(name), options
  end

  def select_options_tag(name, list, options={})
    list = list.map{|x| x.is_a?(Array) ? [x[0],h(x[1])] : h(x) } # stringify values from lists
    selected = h(options[:value] || params.value_from_nested_key(name))
    select_tag(name, options_for_select(list,selected), options.except(:value))
  end

  def params_radio_button_with_label(name, value, label, options={})
    checked = options.fetch(:value){ params.value_from_nested_key(name) }
    radio_button_with_label(name, value, checked, label, options)
  end

  def radio_button_with_label(name, value, checked, label, options={})
    label_for = if options[:id]
      options[:id]  # when id was changed, label has to be for this id
    else
      # name[hello][world] -> name_hello_world_
      # name[hello][] -> name_hello_world__
      # name -> name_
      clean_name = name.to_s.gsub('[]','_').gsub('][','_').gsub(/[\]\[]/,'_')
      clean_name += '_' unless clean_name =~ /_$/
      clean_name + value.to_s.downcase
    end
    radio_button_tag(name, value, checked) + label_tag(label_for, label)
  end
end
