worker_processes 2
preload_app true
timeout 30
listen 5000

# unicorn 日志

stderr_path APP_PATH + "/log/unicorn.stderr.log"

stdout_path APP_PATH + "/log/unicorn.stdout.log"

after_fork do |server, worker|
  ActiveRecord::Base.establish_connection
end