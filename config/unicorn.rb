worker_processes 2
preload_app true
timeout 180
listen 5000

require 'pathname'

path = Pathname.new(__FILE__).realpath # 当前文件完整路径

path = path.sub('/config/unicorn.rb', '')

APP_PATH = path.to_s

# unicorn 日志

stderr_path APP_PATH + "/log/unicorn.stderr.log"

stdout_path APP_PATH + "/log/unicorn.stdout.log"

after_fork do |server, worker|
  ActiveRecord::Base.establish_connection
end
