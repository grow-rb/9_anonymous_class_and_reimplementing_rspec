# Anonymous Classes

There are two ways to define classes in Ruby: using the `class` keyword and using `Class.new`.

## class

The `class` keyword defines a class while moving the context inside that class.

This method of class definition is common, but it has several constraints. For example:

* Names cannot be specified dynamically
* Variables outside the `class` keyword cannot be accessed

These constraints usually don't pose much of a problem, but when they do become problematic, we use `Class.new` as described below.

## Class.new

In Ruby's world, classes are objects, so they can be created with the `new` method. Classes created this way are anonymous until they are assigned to a constant, which is why they are sometimes called "anonymous classes."

With anonymous classes, you can assign names dynamically, and when you don't need to name them, you can leave them anonymous. Also, since they don't create variable scope, when combined with `define_method`, you can use variables in the current scope inside the class definition.

Let's look at an example:

```ruby
lvar = "foo"
klass = Class.new do
  define_method :foo do
    lvar
  end
end

Object.const_set("Class_#{1+1}", klass)
puts Class_2.new.foo
# => foo
```

## Review of DSL Construction

What is commonly used when building DSLs is `instance_eval`. There's also a technique of creating an application class for DSL evaluation and using each DSL as a pointer to it (like Rake). However, these methods have constraints. Since scope is not separated, when you define methods, the definitions leak out to the `main` object.

Let's try running the following code with `rake foo:bar`:

```ruby
# Place in any directory
# Rakefile

namespace :foo do
  desc 'Sample task'
  task :bar do
    bar
  end

  def bar
    puts 'bar'
  end
end

bar # This should cause an error
```

You'll see `bar` output twice. This is because the `bar` at the bottom doesn't cause an error. While this may seem counterintuitive at first, if you understand that the `namespace` method doesn't create a class definition, you'll realize that `def bar` ends up being a method definition for the `main` object.

## Creating Anonymous Classes from DSLs

What about RSpec's DSL? Let's try running the following code with `rspec foo_spec.rb`:

```ruby
# foo_spec.rb
require 'rspec'

RSpec.describe 'This is the description' do
  describe 'This is inner description' do
    def some_method
      puts self.class
    end
    it 'works' do
      some_method
    end
  end
end

some_method
```

This time it should cause an error. Now, remove the `some_method` call at the bottom and run it again. You should get output like `RSpec::ExampleGroups::ThisIsTheDescription::ThisIsInnerDescription`. This is the result of `puts self.class`, so you can see that `def some_method` is defined for this class (that you don't remember defining).

What's being used here is anonymous classes. Since anonymous classes can be given names later, it's possible to determine class names based on the strings given to the `describe` method, as shown above.

## Methods in Anonymous Classes

To define methods for classes created with `Class.new`, you provide a block to `Class.new` and define methods normally within it.

```ruby
klass = Class.new do
  def foo
    puts 'foo'
  end
end

klass.new.foo # => foo
```

## Parent Classes of Anonymous Classes

When you provide an argument to `Class.new`, that class becomes the parent class.

```ruby
class Parent
  def foo
    puts 'foo'
  end
end

Child = Class.new(Parent)
Child.new.foo # => foo
```
