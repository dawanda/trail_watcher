class Trail
  include Mongoid::Document
  include Mongoid::Timestamps

  field :path, :type => String # ;/foo;/bar;
  field :tags, :type => Array # registered, relogin, login

  TIMEOUT = 1.hour
  SEPARATOR = ';'
  MATCH_ANY_PATH_IN_BETWEEN = ";(.*;)?"

  def self.with_paths_in_order(paths)
    where :path => /#{SEPARATOR}#{paths.join MATCH_ANY_PATH_IN_BETWEEN}#{SEPARATOR}/
  end

  def self.track!(options)
    raise unless options[:path]

    path = options[:path].gsub(SEPARATOR,'-sep-')
    referrer = options[:referrer].to_s.gsub(SEPARATOR,'-sep-')
    tags = options[:tags].to_s.split(',').reject(&:blank?)

    if options[:id] and trail = where(:created_at.gt => TIMEOUT.ago).find_by_id(options[:id])
      trail.update_attributes(:path => trail.path + path + SEPARATOR, :tags => unique_tag_groups(trail.tags + tags, CFG[:tag_groups] || []).uniq)
    else
      path = SEPARATOR + [referrer, path].reject(&:blank?).join(SEPARATOR) + SEPARATOR
      trail = create!(:path => path, :tags => unique_tag_groups(tags, CFG[:tag_groups] || []))
    end

    trail.id
  end

  def paths
    path.to_s[1..-2].split(SEPARATOR)
  end

  private

  # remove all but one tag from the same group
  # [a,b,c] with group=[a,b] --> [a,c]
  def self.unique_tag_groups(tags, groups)
    tags.uniq_by{|tag| groups.detect{|g| g.include?(tag) } || tag }
  end
end
