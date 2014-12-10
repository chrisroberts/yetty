require 'paint'

module Yetty
  class Ui

    # @return [Truthy, Falsey]
    attr_accessor :colorize

    # Build new UI instance
    #
    # @param args [Hash]
    # @option args [TrueClass, FalseClass] :color enable/disable colors
    # @option args [IO] :output_to IO to write
    # @return [self]
    def initialize(args={})
      @colorize = args.fetch(:colors, true)
      @output_to = args.fetch(:output_to, $stdout)
    end

    # Output directly
    #
    # @param string [String]
    # @return [String]
    def puts(string='')
      @output_to.puts string
      string
    end

    # Output directly
    #
    # @param string [String]
    # @return [String]
    def print(string='')
      @output_to.print string
      string
    end

    # Output information string
    #
    # @param string [String]
    # @return [String]
    def info(string, *args)
      output_method = args.include?(:nonewline) ? :print : :puts
      self.send(output_method, "#{color('[Yetty]:', :green)} #{string}")
      string
    end

    # Format warning string
    #
    # @param string [String]
    # @return [String]
    def warn(string, *args)
      output_method = args.include?(:nonewline) ? :print : :puts
      self.send(output_method, "#{color('[WARN]:', :yellow, :bold)} #{string}")
      string
    end

    # Format error string
    #
    # @param string [String]
    # @return [String]
    def error(string, *args)
      output_method = args.include?(:nonewline) ? :print : :puts
      self.send(output_method, "#{color('[ERROR]:', :red, :bold)} #{string}")
      string
    end

    # Colorize string
    #
    # @param string [String]
    # @param args [Symbol]
    # @return [String]
    def color(string, *args)
      Paint[string, *args]
    end

    # Prompt for question and receive answer
    #
    # @param question [String]
    # @param default [String]
    # @return [String]
    def ask(question, default=nil)
      string = question.dup
      if(default)
        string << " [#{default}]"
      end
      result = nil
      until(result)
        info "#{string}: ", :nonewline
        result = $stdin.gets.strip
        if(result.empty? && default)
          result = default
        end
        if(result.empty?)
          error 'Please provide a value'
          result = nil
        end
      end
      result
    end

  end
end
