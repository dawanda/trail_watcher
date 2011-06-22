require 'erb'
require 'active_support/core_ext/hash/indifferent_access'

module CFGLoader
  extend self

  def read(files, options={})
    config = {}
    [*files].each do |file|
      next unless File.exist? file
      data = YAML::load(ERB.new((IO.read(file))).result)[options[:rails_env] || Rails.env]
      data ||= {}
      config.merge!(data)
    end
    config
  end
end

CFG = CFGLoader.read(["#{Rails.root}/config/config.yml","#{Rails.root}/config/config.local.yml"]).with_indifferent_access.freeze
