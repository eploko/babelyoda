require 'log4r'

unless $logger
  Log4r::Logger.root.level = ENV['DEBUG'] ? Log4r::DEBUG : (ENV['VERBOSE'] ? Log4r::INFO : Log4r::WARN)

  Log4r::StdoutOutputter.new 'console', {
    :formatter => Log4r::PatternFormatter.new(:pattern => "%l %m")
  }

  $logger = Log4r::Logger.new('babelyoda')
  $logger.add('console')
end
