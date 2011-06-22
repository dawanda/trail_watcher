class Trail
  include Mongoid::Document
  include Mongoid::Timestamps

  field :account_state, :type => String # registered, relogin, login
  field :path, :type => String # ;/foo;/bar;

  TIMEOUT = 1.hour

  def self.track!(options)
    raise unless options[:path]

    attributes = Hash[options.select{|k,v| k.to_s.starts_with?('data-')}.map{|k,v| [k.sub('data-',''),v] }]

    if options[:id] and trail = where(:created_at.gt => TIMEOUT.ago).find_by_id(options[:id])
      trail.update_attributes(attributes.merge(:path => trail.path + options[:path] + ';'))
    else
      path = ';' + [options[:referrer], options[:path]].reject(&:blank?).join(';') + ';'
      trail = create!(attributes.merge(:path => path))
    end

    trail.id
  end

  def paths
    path.to_s[1..-2].split(';')
  end
end
