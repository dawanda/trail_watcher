class Trail
  include Mongoid::Document
  include Mongoid::Timestamps

  field :path, :type => String # ;/foo;/bar;
  field :tags, :type => Array # registered, relogin, login
  field :user_id, :type => Integer

  TIMEOUT = 5.minutes
  SEPARATOR = ';'

  def self.with_paths_in_order(paths, options={})
    paths = paths.map{|p| "#{p};" }
    path_matcher = paths.join "([^;]*;){0,#{options[:between] || 0}}"
    where :path => /;#{path_matcher}/
  end

  def self.track!(options)
    raise unless options[:path]

    unless trail = where(:created_at.gt => TIMEOUT.ago).find_by_id(options[:id])
      trail = create!(:path => SEPARATOR, :user_id => options[:user_id])
      trail.append_path options[:referrer]
    end

    all_tags = ((trail.tags || []) + options[:tags].to_s.split(',').reject(&:blank?)).uniq

    trail.append_path options[:path]
    trail.tags = unique_tag_groups(all_tags, CFG[:tag_groups] || [])
    trail.save!

    trail.id
  end

  def self.with_all_tags(*tags)
    tags = tags.reject{ |tag| tag == 'all' or tag.blank? }
    if tags.size > 0
      all_in(:tags => tags)
    else
      where()
    end
  end

  def append_path(path)
    self.path += path.gsub(SEPARATOR,'-sep-') + SEPARATOR if path.present?
  end

  def paths
    path.to_s[1..-2].split(SEPARATOR)
  end

  def self.tags
    where.distinct(:tags).sort
  end

  def self.between_dates(from, to, options={})
    # add expanded time when time is not given
    to += ' 23:59:59' if options[:expand_to] and to.present? and to.to_s !~ /\d\d:\d\d:\d\d/

    scope = where
    scope = scope.where(:created_at.gte => from.to_time) if from.present?
    scope = scope.where(:created_at.lte => to.to_time) if to.present?
    scope
  end

  def self.for_user(id)
    where(:user_id => id)
  end

  private

  # remove all but one tag from the same group
  # [a,b,c] with group=[a,b] --> [a,c]
  def self.unique_tag_groups(tags, groups)
    tags.uniq_by{|tag| groups.detect{|g| g.include?(tag) } || tag }
  end
end
