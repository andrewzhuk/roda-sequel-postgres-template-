# frozen_string_literal: true

require 'erb'
require 'logger'
require 'yaml'

require_relative '../../application/version'
# no doc
module Application
  require_relative 'logging'

  def self.env
    @env ||= (ENV['APPLICATION_ENV'] || 'development').to_sym
  end

  def self.root
    @root ||= File.expand_path('../..', __dir__)
  end

  def self.settings
    @settings ||= begin
      config_file = ["#{root}/config/application.yml"].find { |f| File.exist?(f) }
      settings = {}
      YAML.safe_load(ERB.new(File.read(config_file)).result, aliases: true)[env.to_s].each do |k, v|
        settings[k.to_sym] = v
      end
      settings[:debug] = true
      settings
    end
  end

  def self.models
    Models.module_eval do
      constants.collect do |constant|
        c = const_get(constant)
        c if c.is_a?(Class)
      end.compact
    end
  end

  def self.serializers
    Serializers.module_eval do
      constants.collect do |constant|
        c = const_get(constant)
        c if c.is_a?(Class)
      end.compact
    end
  end

  def self.logger
    @logger ||= begin
      logger = Logger.new($stdout)
      level = settings[:log_level].to_s.upcase
      logger.level = begin
        Logger.const_get(level).to_i
      rescue StandardError
        1
      end
      logger.formatter = proc do |severity, time, pname, msg|
        "#{time.iso8601(3)} #{::Process.pid} #{pname} #{severity}: #{msg}\n"
      end
      logger
    end
  end

  def self.logger=(logger)
    @logger = logger
  end

  # no doc
  module Utils
    module_function

    def timestamp
      Time.now.strftime('%H:%M:%S')
    end

    def sanitize_options(options)
      # default is 0
      options[:offset] ||= 0
      options[:offset] = [options[:offset].to_i, 0].max
      # default is 20; max is 100
      options[:limit] ||= 20
      options[:limit] = [[options[:limit].to_i, 0].max, 100].min
    end
  end
end

# no doc
class String
  INTEGERREGEX = /^(\d)+$/.freeze

  def truncate(max)
    length > max ? "#{self[0...max]}..." : self
  end

  def try_to_i(default = nil)
    /^\d+$/ == self ? to_i : default
  end

  def integer?
    !!match(INTEGERREGEX)
  end

  def sha1
    Digest::SHA1.hexdigest to_s
  end
end

class Hash
  def sha1
    Digest::SHA1.hexdigest to_s
  end
end
