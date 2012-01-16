module Babelyoda
  module Engine
    class Base
      def list ; raise NotImplementedError ; end
      def drop(keyset_name) ; raise NotImplementedError ; end
      def create(keyset_name) ; raise NotImplementedError ; end
      def replace(name, strings, language = 'en') ; raise NotImplementedError ; end
      
      def load_keyset(name) ; raise NotImplementedError ; end
      def save_keyset(keyset, langs = keyset.langs) ; raise NotImplementedError ; end
      def load_strings(filename) ; raise NotImplementedError ; end
      def save_strings(strings, filename) ; raise NotImplementedError ; end
      def push_strings(strings, name) ; raise NotImplementedError ; end
      def pull_keyset(name) ; raise NotImplementedError ; end
    end
  end
end
