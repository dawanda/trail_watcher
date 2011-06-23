require 'erb'
require 'active_support/core_ext/hash/indifferent_access'

module CFGLoader
  def self.load
    file = "config/config.yml"
    YAML::load(ERB.new((IO.read(file))).result).with_indifferent_access.freeze
  end
end
