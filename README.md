# 無名クラス

Rubyでクラスを定義するには2通りの方法があります。`class`キーワードと`Class.new`です。

## class

`class`キーワードはクラス定義しつつそのクラスの中にコンテキストを移します。

このクラス定義の仕方は一般的ですが、一方でいくつかの制約があります。例えば、

* 名前を動的に指定できない
* `class`キーワードの外部にある変数にアクセスできない

これらの制約は通常あまり問題になりませんが、問題になるケースでは以下の`Class.new`を使います。

## Class.new

Rubyの世界ではクラスはオブジェクトですので、`new`メソッドで作ることができます。この方法で作られたクラスは定数に代入されるまで無名なので「無名クラス」と言われることもあります。

無名クラスでは動的に名前付けができますし、名前をつける必要がないときは無名のままにできます。また、変数のスコープを作らないため、`define_method`と組み合わせることで現在のスコープにある変数をクラス定義の内部で使うことができます。

例を見てみましょう。

```ruby
lvar = "foo"
klass = Class.new do
  define_method :foo do
    foo
  end
end

Object.const_set("Class_#{1+1}", klass)
puts Class_2.new.foo
# => foo
```

## DSLの作り方をおさらい

DSLを構築する際に多く使われるのは`instance_eval`です。また、アプリケーションクラスと呼ばれるDSL評価用のクラスを作って各DSLをそこへのポインタ的に使う手法もあります（Rakeなど）。しかし、これらの方法には制約があります。スコープが区切られないため、メソッドを定義すると定義が`main`オブジェクトに漏れ出してしまうのです。

試しに、以下のコードを`rake foo:bar`で実行してみましょう。

```ruby
# 適当なディレクトリに配置
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

bar # これはエラーになってほしい
```

すると`bar`が2回出力されます。これは一番下の`bar`がエラーになっていないことによるものです。これは一見直観に反しますが、`namespace`メソッドがクラス定義をしているわけではない、ということを理解すると結局`def bar`は`main`オブジェクトに対してのメソッド定義になっていることがわかるかと思います。

## DSLから無名クラスを作る

では、RSpecのDSLではどうでしょうか。以下のコードを`rspec foo_spec.rb`などで実行してみましょう。

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

今度はエラーになったかと思います。ここで、最下部の`some_method`呼び出しを削除して再実行してみましょう。すると、`RSpec::ExampleGroups::ThisIsTheDescription::ThisIsInnerDescription`のような出力が得られます。これは`puts self.class`の結果ですので、`def some_method`はこの（定義した覚えのない）クラスに対して定義されていることがわかります。

ここで使われているのが無名クラスです。無名クラスには名前を後から与えることができるので、上のように`describe`メソッドに与えた文字列を元にクラス名を決定することもできるわけですね。

## 無名クラスのメソッド

`Class.new`で定義したクラスに対してメソッドを定義するには`Class.new`にブロックを与え、その中で通常通りメソッドを定義します。

```ruby
klass = Class.new do
  def foo
    puts 'foo'
  end
end

klass.new.foo # => foo
```

## 無名クラスの親クラス

`Class.new`に引数を与えるとそのクラスは親クラスになります。

```ruby
class Parent
  def foo
    puts 'foo'
  end
end

Child = Class.new(Parent)
Child.new.foo # => foo
```
