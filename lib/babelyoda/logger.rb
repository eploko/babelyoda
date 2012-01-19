require 'term/ansicolor'

module Babelyoda
  class Logger
    include Term::ANSIColor
    
    def exe(cmd) ; putcmd cmd ; system cmd ; end
    def putcmd(cmd) ; print magenta, "CMD: #{cmd}", reset, "\n" ; end
    def status(msg) ; print blue, "--- #{msg} ---", reset, "\n" ; end
    def success(msg, heading = true) ; print green, bold, (heading ? 'SUCCESS: ' : ''), msg, reset, "\n" ; end
    def error(msg, heading = true, do_exit = true) ; print red, bold, (heading ? 'ERROR: ' : ''), msg, reset, "\n" ; exit 1 if do_exit; end
    def escape_cmd_args(args) ; args.collect{ |arg| "'#{arg}'"}.join(' ') ; end
  end
end

$logger ||= Babelyoda::Logger.new
