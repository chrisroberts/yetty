require 'yetty'

module Yetty
  # Abstract command class
  class Command

    # @return [Hash] options
    attr_reader :options
    # @return [Array] cli arguments
    attr_reader :arguments
    # @return [Ui]
    attr_reader :ui

    # Default configuration file locations
    DEFAULT_CONFIGURATION_FILES = [
      './.yetty',
      '~/.yetty',
      '/etc/yetty/config.json'
    ]

    # Build new command instance
    #
    # @return [self]
    def initialize(opts, args)
      @options = opts.to_smash
      @arguments = args
      @ui = Ui.new
      load_config!
    end

    # Execute the command
    #
    # @return [TrueClass]
    def execute!
      raise NotImplementedError
    end

    protected

    # Command specific options
    #
    # @return [Hash]
    def opts
      options.fetch(self.class.name.split('::').last.downcase, {})
    end

    # User specific options
    #
    # @return [Hash]
    def user
      result = options[:user]
      unless(result)
        raise 'No user information defined!'
      else
        result.to_smash
      end
    end

    # @return [Miasma::Models::Storage]
    def storage
      if(user[:storage])
        Miasma.api(
          :type => :storage,
          :provider => user[:storage][:provider],
          :credentials => user[:storage][:credentials]
        )
      else
        raise 'No remote storage configuration found!'
      end
    end

    # @return [Miasma::Models::Storage::Bucket]
    def bucket
      unless(user.get(:storage, :bucket))
        raise 'No bucket defined within storage configuration!'
      end
      bucket = storage.buckets.get(user[:storage][:bucket])
      unless(bucket)
        bucket = storage.buckets.build
        bucket.name = user[:storage][:bucket]
        bucket.save
        bucket = storage.buckets.reload.get(user[:storage][:bucket])
      end
      bucket
    end

    # Load configuration file and merge opts
    # on top of file values
    #
    # @return [Hash]
    def load_config!
      if(options[:config])
        content = File.read(options[:config])
      else
        path = DEFAULT_CONFIGURATION_FILES.detect do |check|
          full_check = File.expand_path(check)
          File.exists?(full_check)
        end
        content = File.read(path) if path
      end
      if(content)
        @options = MultiJson.load(content).to_smash.deep_merge(options)
      end
    end

    # Wrap action within nice text. Output resulting Hash if provided
    #
    # @param msg [String] message of action in progress
    # @yieldblock action to execute
    # @yieldreturn [Hash] result to output
    # @return [TrueClass]
    def run_action(msg)
      ui.info("#{msg}... ", :nonewline)
      begin
        result = yield
        ui.puts ui.color('complete!', :green, :bold)
        if(result.is_a?(Hash))
          ui.puts '---> Results:'
          result.each do |k,v|
            ui.puts "    #{ui.color("#{k}:", :bold)} #{v}"
          end
        end
      rescue => e
        ui.puts ui.color('error!', :red, :bold)
        ui.error "Reason - #{e}"
        raise
      end
      true
    end

  end
end
