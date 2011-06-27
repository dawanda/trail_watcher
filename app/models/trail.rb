class Trail
  include Mongoid::Document
  include Mongoid::Timestamps

  field :path, :type => String # ;/foo;/bar;
  field :tags, :type => Array # registered, relogin, login

  TIMEOUT = 5.minutes
  SEPARATOR = ';'

  def self.with_paths_in_order(paths, options={})
    paths = paths.map{|p| "#{p};" }
    path_matcher = paths.join "([^;]*;){0,#{options[:between] || 2}}"
    where :path => /;#{path_matcher}/
  end

  def self.track!(options)
    raise unless options[:path]

    unless trail = where(:created_at.gt => TIMEOUT.ago).find_by_id(options[:id])
      trail = create!(:path => SEPARATOR)
      trail.append_path options[:referrer]
    end

    all_tags = ((trail.tags || []) + options[:tags].to_s.split(',').reject(&:blank?)).uniq

    trail.append_path options[:path]
    trail.tags = unique_tag_groups(all_tags, CFG[:tag_groups] || [])
    trail.save!

    trail.id
  end

  def append_path(path)
    self.path += path.gsub(SEPARATOR,'-sep-') + SEPARATOR if path.present?
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
