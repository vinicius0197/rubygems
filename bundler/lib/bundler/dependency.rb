require 'rubygems/dependency'
require 'bundler/shared_helpers'

module Bundler
  class Dependency < Gem::Dependency
    attr_reader :autorequire
    attr_reader :groups
    attr_reader :platforms

    PLATFORM_MAP = {
      :ruby    => Gem::Platform::RUBY,
      :ruby_18 => Gem::Platform::RUBY,
      :ruby_19 => Gem::Platform::RUBY,
      :jruby   => Gem::Platform::JAVA,
      :mswin   => Gem::Platform::MSWIN
    }

    def initialize(name, version, options = {}, &blk)
      super(name, version)

      @autorequire = nil
      @groups      = Array(options["group"] || :default).map { |g| g.to_sym }
      @source      = options["source"]
      @platforms   = Array(options["platforms"])

      if options.key?('require')
        @autorequire = Array(options['require'] || [])
      end
    end

    def gem_platforms(valid_platforms)
      return valid_platforms if @platforms.empty?

      platforms = []
      @platforms.each do |p|
        platform = PLATFORM_MAP[p]
        next unless valid_platforms.include?(platform)
        platforms |= [platform]
      end
      platforms
    end

    def current_platform?
      return true if @platforms.empty?
      @platforms.any? { |p| send("#{p}?") }
    end

    def to_lock
      out = "  #{name}"

      unless requirement == Gem::Requirement.default
        out << " (#{requirement.to_s})"
      end

      out << '!' if source

      out << "\n"
    end

  private

    def ruby?
      !mswin? && (!defined?(RUBY_ENGINE) || RUBY_ENGINE == "ruby" || RUBY_ENGINE == "rbx")
    end

    def ruby_18?
      ruby? && RUBY_VERSION < "1.9"
    end

    def ruby_19?
      ruby? && RUBY_VERSION >= "1.9"
    end

    def jruby?
      RUBY_ENGINE == "jruby"
    end

    def mswin?
      # w0t?
    end
  end
end
