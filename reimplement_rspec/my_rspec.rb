class MyRSpec
  class ExampleGroup
    attr_writer :before
    def initialize(description)
      @description = description
      # コールバックの初期化が必要…？
    end

    def it(message)
      # コールバックを実行するには…？
      print message
      yield if block_given?
    end

    def describe(description = nil, &block)
      # 動的にクラスを生成したい
    end

    def before(&block)
      # コールバックを複数段階設定できるようにしたい
    end
  end

  def self.describe(description = nil, &block)
    # このメソッドは単なるラッパーっぽい感じにしたい
  end
end

# クラス名を動的にセットする場合に必要
# 実装がしょぼいのはご勘弁を
module Helper
  def camelcase(string)
    str = string.dup
    c = str[0].upcase
    string[0] = c
    string
  end
  module_function :camelcase
end
