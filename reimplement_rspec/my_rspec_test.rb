require 'minitest/autorun'
require_relative 'my_rspec'

class MyRSpecTest < Minitest::Test
  # instance_evalを使えばこれだけなら通せる
  def test_describe
    assert_output 'works' do
      MyRSpec.describe 'foo' do
        it 'works'
      end
    end
  end

  # const_setを使ってクラスを登録したい
  def test_describe_class_name
    skip
    assert_output('MyRSpec::ExampleGroup::Foo') do
      MyRSpec.describe 'foo' do
        print self.class.name
      end
    end
  end

  # 再帰的な構造
  def test_nested_describes
    assert_output 'works' do
      MyRSpec.describe 'foo' do
        describe 'bar' do
          it 'works'
        end
      end
    end
  end

  # const_setの書き方が正しければ自動的に解けるかも？
  def test_nested_describes_class_name
    skip
    assert_output('MyRSpec::ExampleGroup::Foo::Bar') do
      MyRSpec.describe 'foo' do
        describe 'bar' do
          print self.class.name
        end
      end
    end
  end

  # 無名クラスを正しく使えていれば、メソッドの定義がリークしない
  def test_defining_method_in_nested_describes
    assert_output 'workshoge' do
      MyRSpec.describe 'foo' do
        describe 'bar' do
          def hoge
            print 'hoge'
          end

          it 'works' do
            hoge
          end
        end
      end
    end

    assert_raises(NameError) do
      MyRSpec.describe 'foo' do
        describe 'bar' do
          def hoge
            print 'hoge'
          end
        end
      end
      hoge
    end
  end

  # おまけのコールバック、順番に注意
  def test_before
    skip
    assert_output('beforeworks') do
      MyRSpec.describe 'foo' do
        before do
          print 'before'
        end
        it 'works'
      end
    end
  end

  # 多段コールバック、結構難しい
  def test_multiple_before_in_nested_describes
    skip
    assert_output 'before1before2works' do
      MyRSpec.describe 'foo' do
        before do
          print 'before1'
        end
        describe 'bar' do
          before do
            print 'before2'
          end
          it 'works'
        end
      end
    end
  end
end
