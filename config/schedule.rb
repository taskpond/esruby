set :environment, 'development'
# set :whenever_environment, defer { stage }

every 1.minutes do
    rake 'task:notifier:daily_snapshort'
end