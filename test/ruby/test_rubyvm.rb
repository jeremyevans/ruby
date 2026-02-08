# frozen_string_literal: false
require 'test/unit'
require_relative '../lib/parser_support'
require 'objspace'

class TestRubyVM < Test::Unit::TestCase
  def test_stat
    assert_kind_of Hash, RubyVM.stat

    RubyVM.stat(stat = {})
    assert_not_empty stat
  end

  def test_stat_unknown
    assert_raise(ArgumentError){ RubyVM.stat(:unknown) }
    assert_raise_with_message(ArgumentError, /\u{30eb 30d3 30fc}/) {RubyVM.stat(:"\u{30eb 30d3 30fc}")}
  end

  def parse_and_compile
    script = <<~RUBY
      _a = 1
      def foo
        _b = 2
      end
      1.times{
        _c = 3
      }
    RUBY

    ast = RubyVM::AbstractSyntaxTree.parse(script)
    iseq = RubyVM::InstructionSequence.compile(script)

    [ast, iseq]
  end

  def test_keep_script_lines
    omit if ParserSupport.prism_enabled?
    pend if ENV['RUBY_ISEQ_DUMP_DEBUG'] # TODO

    prev_conf = RubyVM.keep_script_lines

    # keep
    RubyVM.keep_script_lines = true

    ast, iseq = *parse_and_compile

    lines = ast.script_lines
    assert_equal Array, lines.class

    lines = iseq.script_lines
    assert_equal Array, lines.class
    iseq.each_child{|child|
      assert_equal lines, child.script_lines
    }
    assert lines.frozen?

    # don't keep
    RubyVM.keep_script_lines = false

    ast, iseq = *parse_and_compile

    lines = ast.script_lines
    assert_equal nil, lines

    lines = iseq.script_lines
    assert_equal nil, lines
    iseq.each_child{|child|
      assert_equal lines, child.script_lines
    }

  ensure
    RubyVM.keep_script_lines = prev_conf
  end

  def test_shape_dup
    c = Class.new
    o = c.new
    n = RubyVM.shape_dup(o)
    assert_instance_of(c, n)
    assert_equal([], n.instance_variables)
    assert_equal(ObjectSpace.memsize_of(c.new), ObjectSpace.memsize_of(n))

    o.instance_variable_set(:@a, 1)
    n = RubyVM.shape_dup(o)
    assert_equal([:@a], n.instance_variables)
    assert_equal([nil], n.instance_variables.map{n.instance_variable_get(it)})
    assert_equal(ObjectSpace.memsize_of(c.new), ObjectSpace.memsize_of(n))

    o.instance_variable_set(:@b, 2)
    n = RubyVM.shape_dup(o)
    assert_equal([:@a, :@b], n.instance_variables)
    assert_equal([nil] * 2, n.instance_variables.map{n.instance_variable_get(it)})
    assert_equal(ObjectSpace.memsize_of(c.new), ObjectSpace.memsize_of(n))

    vars = [:@a, :@b]
    var = "@b"
    76.times do |i|
      var.succ!
      vars << var.to_sym
      o.instance_variable_set(var, i)
    end
    n = RubyVM.shape_dup(o)
    assert_equal(vars, n.instance_variables)
    assert_equal([nil] * vars.length, n.instance_variables.map{n.instance_variable_get(it)})
    assert_equal(ObjectSpace.memsize_of(c.new), ObjectSpace.memsize_of(n))

    o.instance_variable_set(:@over, 0)
    assert_raise(TypeError) { RubyVM.shape_dup(o) }

    assert_raise(TypeError) { RubyVM.shape_dup({}) }
  end
end
