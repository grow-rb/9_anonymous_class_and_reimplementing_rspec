require 'minitest/autorun'
require_relative 'anonymous_class'

class MySuperClass
end

class AnonymousClassTest < Minitest::Test
  def test_defining_anonymous_class
    generated_class = ClassGenerator.new(name: 'MyClass').generate
    assert_equal 'MyClass', generated_class.name
  end

  def test_defining_anonymous_class_with_superclass
    generated_class = ClassGenerator.new(name: 'MySubClass', superclass: MySuperClass).generate
    assert_equal 'MySubClass', generated_class.name
    assert_equal 'MySuperClass', generated_class.superclass.name
  end

  def test_defining_anonymous_class_with_method
    lvar = 'bar'
    generated_class = ClassGenerator.new(name: 'TheClass').generate do
      def self.foo
        'foo'
      end

      define_method :bar do
        lvar
      end
    end
    assert_equal 'TheClass', generated_class.name
    assert_equal 'foo', generated_class.foo
    assert_equal 'bar', generated_class.new.bar
  end
end
