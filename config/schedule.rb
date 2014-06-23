set :environment, 'development'
# set :output, "/path/to/my/cron_log.log"
# set :output, {
#     :error => "#{File.expand_path('log')}/cron_error_log.log",
#     :standard => "#{File.expand_path('log')}/cron_log.log"
# }
# set :whenever_environment, defer { stage }

every 1.minutes do
    rake 'task:notifier:daily_snapshort'
end