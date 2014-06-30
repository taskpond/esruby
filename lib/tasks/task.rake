namespace :task do
    namespace :notifier do
        desc "send daily snapshort"
        task :daily_snapshort, [:user_id] => :environment do |t, args|
            args.with_defaults(:user_id => 369)
            start_job = Time.now
            puts "start #{start_job}"
            notify = Es.new
            # notify.daily args.user_id
            users = User.all
            users.each do |user|
                notify.daily user.ids
            end
            end_job
            puts "end #{end_job}"
            puts (start_job - end_job).abs
        end
    end
end