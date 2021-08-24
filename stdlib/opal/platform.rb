require 'opal-platform'

case OPAL_PLATFORM
when 'nashorn'
  require 'nashorn'
when 'gjs'
  require 'gjs'
when 'nodejs'
  require 'nodejs/kernel'
  require 'nodejs/io'
when 'headless-chrome'
  require 'headless_chrome'
end
