require 'test_helper'

class BooleanExpressionsTest < MiniTest::Unit::TestCase
  %w(== != > >= < <= % <<).each do |operator|
    define_method(:"test_#{operator}") do
      parses "foo #{operator} 3" do |nodes|
        exp = nodes.first

        assert_kind_of CallNode, exp
        assert_equal :foo, exp.receiver.name
        assert_equal operator, exp.method
        assert_equal 3, exp.arguments.first.value
      end
    end
  end

  %w(! -).each do |operator|
    define_method(:"test_unary_#{operator}") do
      parses "#{operator}3" do |nodes|
        exp = nodes.first

        assert_kind_of CallNode, exp
        assert_equal 3, exp.receiver.value
        assert_equal "#{operator}@", exp.method
      end
    end
  end
end
