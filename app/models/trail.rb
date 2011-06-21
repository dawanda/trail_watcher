class Trail
  include Mongoid::Document
  include Mongoid::Timestamps
  embeds_many :visits
  TIMEOUT = 1.hour

  def self.track!(options)
    raise unless options[:path]

    unless options[:id] and trail = where(:created_at.gt => TIMEOUT.ago).find_by_id(options[:id])
      trail = create!
      trail.visits.create!(:path => options[:referrer]) if options[:referrer].present?
    end
    trail.visits.create!(:path => options[:path])
    trail.id
  end
end
