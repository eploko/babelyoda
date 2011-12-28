module Babelyoda
  module Engine
    class Base
      def load_keyset(name) ; raise NotImplementedError ; end
      def save_keyset(keyset, langs = keyset.langs) ; raise NotImplementedError ; end
    end
  end
end
