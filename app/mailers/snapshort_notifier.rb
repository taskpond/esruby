class SnapshortNotifier < ActionMailer::Base
    default from: "no-reply@example.com"

    def daily_snapshort(email, subject, data)
        @result = data
        mail( to: email, subject: subject) do |format|
            format.html { render 'daily_snapshort' }
        end
    end
end
