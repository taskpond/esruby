namespace :task do
    namespace :notifier do
        desc "send daily snapshort"
        task :daily_snapshort, [:user_id] => :environment do |t, args|
            args.with_defaults(:user_id => 573)
            notify = Es.new
            notify.daily args.user_id
        end
    end
end