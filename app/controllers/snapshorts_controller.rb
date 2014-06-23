class SnapshortsController < ApplicationController
    before_filter :fetch_data, only: [:daily]
    before_filter :fetch_user, only: [:index]

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

        @result.aggregations.Assignee.buckets.each do |bucket|
            @archievement = bucket.Month2Date
            @schedule     = bucket.ComingTasksDue.Range
        end

        SnapshortNotifier.daily_snapshort('user@example.com', 'Daily Snapshort', @result).deliver

        render layout: false
    end
end