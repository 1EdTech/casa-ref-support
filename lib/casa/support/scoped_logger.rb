require 'logger'

module CASA
  module Support
    class ScopedLogger < SimpleDelegator

      class << self
        def new_without_scope logdev, shift_age = 0, shift_size = 1048576
          ::CASA::Support::ScopedLogger.new nil, logdev, shift_age, shift_size
        end
      end

      attr_accessor :scope

      def initialize starting_scope, logdev, shift_age = 0, shift_size = 1048576
        if logdev.is_a? ::Logger or logdev.is_a? ::CASA::Support::ScopedLogger
          super logdev
        else
          super ::Logger.new logdev, shift_age, shift_size
        end
        @scope = starting_scope
      end

      def scoped_block name = nil, &block
        yield ScopedLogger.new @scope ? "#{@scope} - #{name}" : name, __getobj__
      end

      def scoped_progname progname = nil
        if @scope
          progname = progname ? "#{@scope} - #{progname}" : @scope
        else
          progname = @scope ? @scope : nil
        end
      end

      def add severity, message = nil, progname = nil, &block
        __getobj__.add(severity, message, scoped_progname(progname), &block)
      end

      [:debug, :error, :fatal, :info, :unknown, :warn].each do |method|
        define_method(method) { |progname = nil, &block| __getobj__.send(method, scoped_progname(progname), &block) }
      end

    end
  end
end
