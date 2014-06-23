class Snapshorts < ActionMailer::Base
  default from: "from@example.com"

  def daily(email, subject, data)
    @archievement = {}
    @schedule     = {}
    @assign_to_me = {}
    @assign_by_me = {}
    @my_todo      = {}

    data.aggregations.Assignee.buckets.each do |bucket|
        @archievement = bucket.Month2Date
        @schedule     = bucket.ComingTasksDue.Range
    end

    mail( to: email, subject: subject)
  end
end
