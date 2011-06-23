class Trail
  include Mongoid::Document
  include Mongoid::Timestamps

  field :path, :type => String # ;/foo;/bar;
  field :tags, :type => Array # registered, relogin, login

  TIMEOUT = 1.hour

  def self.track!(options)
    raise unless options[:path]
    tags = options[:tags].to_s.split(',').reject(&:blank?)

    if options[:id] and trail = where(:created_at.gt => TIMEOUT.ago).find_by_id(options[:id])
      trail.update_attributes(:path => trail.path + options[:path] + ';', :tags => (trail.tags + tags).uniq)
    else
      path = ';' + [options[:referrer], options[:path]].reject(&:blank?).join(';') + ';'
      trail = create!(:path => path, :tags => tags.uniq)
    end

    trail.id
  end

  def paths
    path.to_s[1..-2].split(';')
  end
end
