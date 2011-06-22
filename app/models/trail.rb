class Trail
  include Mongoid::Document
  include Mongoid::Timestamps
  embeds_many :visits
  field :account_state, :type => String # registered, relogin, login

  TIMEOUT = 1.hour

  def self.track!(options)
    raise unless options[:path]

    attributes = Hash[options.select{|k,v| k.to_s.starts_with?('data-')}.map{|k,v| [k.sub('data-',''),v] }]

    if options[:id] and trail = where(:created_at.gt => TIMEOUT.ago).find_by_id(options[:id])
      trail.update_attributes(attributes)
    else
      trail = create!(attributes)
      trail.visits.create!(:path => options[:referrer]) if options[:referrer].present?
    end
    trail.visits.create!(:path => options[:path])
    trail.id
  end
end
