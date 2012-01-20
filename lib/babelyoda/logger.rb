require 'log4r-color'

unless $logger
  Log4r::Logger.root.level = ENV['DEBUG'] ? Log4r::DEBUG : (ENV['VERBOSE'] ? Log4r::INFO : Log4r::WARN)

  Log4r::ColorOutputter.new 'color', {
    :colors => { 
      :debug  => :black, 
      :info   => :blue, 
      :warn   => :yellow, 
      :error  => :red, 
      :fatal  => {:color => :red, :background => :white} 
    },
    :formatter => Log4r::PatternFormatter.new(:pattern => "%l %m")
  }

  $logger = Log4r::Logger.new('babelyoda')
  $logger.add('color')
end
