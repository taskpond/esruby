class SnapshortNotifier < ActionMailer::Base
    default from: "from@example.com"

    def daily_snapshort(email, subject, data)
        @archievement = {}
        @schedule     = {}
        @assign_to_me = {}
        @assign_by_me = {}
        @my_todo      = {}

        data.aggregations.Assignee.buckets.each do |bucket|
            @archievement = bucket.Month2Date
            @schedule     = bucket.ComingTasksDue.Range
        end

        mail( to: email, subject: subject) do |format|
            format.html { render 'daily_snapshort' }
        end
    end
end
