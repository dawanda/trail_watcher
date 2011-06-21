module Mongoid::Document::ClassMethods
  def find_by_id(id)
    where(:_id => id).first
  end
end
