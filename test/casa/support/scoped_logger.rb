require 'test/unit'
require 'casa/support/scoped_logger'

class TestCASASupportScopedLogger < Test::Unit::TestCase

  LOG_TYPES = {:debug => 'D', :error => 'E', :fatal => 'F', :info => 'I', :unknown => 'A', :warn => 'W'}

  def test_attr_access
    logger = CASA::Support::ScopedLogger.new 'scope1', '/dev/null'
    assert logger.scope == 'scope1'
    logger.scope = 'scope2'
    assert logger.scope == 'scope2'
  end

  def test_initializations
    inner = CASA::Support::ScopedLogger.new 'inner', '/dev/null'
    outer = CASA::Support::ScopedLogger.new 'outer', inner
    assert inner.__getobj__.is_a? Logger
    assert outer.__getobj__ == inner
    without_scope = CASA::Support::ScopedLogger.new_without_scope('/dev/null')
    assert without_scope.is_a? CASA::Support::ScopedLogger
    assert without_scope.scope.nil?
  end

  def test_scoped_progame
    assert CASA::Support::ScopedLogger.new('test', '/dev/null').scoped_progname == 'test'
    assert CASA::Support::ScopedLogger.new('test', '/dev/null').scoped_progname('test2') == 'test - test2'
    assert CASA::Support::ScopedLogger.new_without_scope('/dev/null').scoped_progname('test3') == 'test3'
    assert CASA::Support::ScopedLogger.new_without_scope('/dev/null').scoped_progname.nil?
  end

  def test_callforward

    strio = StringIO.new

    scope_name = 'xxxxxxx'
    logger = CASA::Support::ScopedLogger.new scope_name, strio

    assert logger.__getobj__.is_a? Logger

    LOG_TYPES.each do |method, letter|
      string = "Type #{method}"
      logger.send(method) { string }
      strio.rewind
      assert strio.readlines.last.match /^#{letter}, \[.*\].* -- #{scope_name}: #{string}$/
    end

  end

  def test_callforward_with_subscope

    strio = StringIO.new

    scope_name = 'yyyyyy'
    logger = CASA::Support::ScopedLogger.new scope_name, strio

    assert logger.__getobj__.is_a? Logger

    LOG_TYPES.each do |method, letter|
      string = "Type #{method}"
      subscope = 'testing'
      logger.send(method, subscope) { string }
      strio.rewind
      assert strio.readlines.last.match /^#{letter}, \[.*\].* -- #{scope_name} - #{subscope}: #{string}$/
    end

  end

  def test_callforward_with_superscope_subscope

    strio = StringIO.new

    parent_scope_name = 'yyyyyy'
    parent_scope = CASA::Support::ScopedLogger.new parent_scope_name, strio

    scope_name = 'xxxxxx'
    logger = CASA::Support::ScopedLogger.new scope_name, parent_scope

    LOG_TYPES.each do |method, letter|
      string = "Type #{method}"
      subscope = 'testing'
      logger.send(method, subscope) { string }
      strio.rewind
      assert strio.readlines.last.match /^#{letter}, \[.*\].* -- #{parent_scope_name} - #{scope_name} - #{subscope}: #{string}$/
    end

  end

  def test_scoped_block

    logger = CASA::Support::ScopedLogger.new 'test', '/dev/null'
    logger.scoped_block do |scoped_logger|
      assert logger == scoped_logger.__getobj__
    end

  end

end