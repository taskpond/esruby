class SnapshortNotifier < ActionMailer::Base
    default from: "Taskworld<no-reply@example.com>"

    def daily_snapshort(email, subject, data)
        @result       = data[:result]
        @assign_to_me = data[:assign_to_me]
        @assign_by_me = data[:assign_by_me]
        @my_todo      = data[:my_todo]
        @following    = data[:following]
        @from         = Es::FROMDUMMY

        mail( to: email, subject: subject) do |format|
            format.html { render 'daily_snapshort' }
        end
    end
end
