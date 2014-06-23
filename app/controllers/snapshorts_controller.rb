class SnapshortsController < ApplicationController

    def index
        @users = Hashie::Mash.new User.new(@users).extend(UserRepresenter).to_hash
    end

    def show
    end

    def daily

        @archievement = {}
        @schedule     = {}
        @assign_to_me = {}
        @assign_by_me = {}
        @my_todo      = {}
        user_id = params[:user_id].present? ? params[:user_id] : 57
        @result = Es.new
        @result = @result.fetch_data(user_id)
        @result.aggregations.Assignee.buckets.each do |bucket|
            @archievement = bucket.Month2Date
            # @schedule     = bucket.ComingTasksDue.Range
        end
        # byebug
        # SnapshortNotifier.daily_snapshort('user@example.com', 'Daily Snapshort', @result).deliver

        return render layout: nil
    end
end