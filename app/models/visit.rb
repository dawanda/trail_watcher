class Visit
  include Mongoid::Document
  include Mongoid::Timestamps

  field :path, :type => String
  embedded_in :trail
end
