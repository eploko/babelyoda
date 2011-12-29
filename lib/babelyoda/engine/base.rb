module Babelyoda
  module Engine
    class Base
      def load_keyset(name) ; raise NotImplementedError ; end
      def save_keyset(keyset, langs = keyset.langs) ; raise NotImplementedError ; end
      def load_strings(filename) ; raise NotImplementedError ; end
      def save_strings(strings, filename) ; raise NotImplementedError ; end
    end
  end
end
