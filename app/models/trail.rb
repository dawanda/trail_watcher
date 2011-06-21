class Trail
  include Mongoid::Document
  include Mongoid::Timestamps
  embeds_many :visits

  def self.track!(options)
    unless options[:id] and trail = find_by_id(options[:id])
      trail = create!
    end
    trail.id
  end
end
