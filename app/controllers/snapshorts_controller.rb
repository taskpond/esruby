require 'mathn'

class SnapshortsController < ApplicationController
    layout false, only: [:daily]

    def index
        @users = Hashie::Mash.new User.new(@users).extend(UserRepresenter).to_hash
    end

    def show
    end

    def daily
        if params[:user_id].present? && !params[:user_id].to_i.zero?
            @data         = Es.new
            @from         = Es::FROMDUMMY
            user_id       = params[:user_id].to_i
            @result       = @data.fetch_data(user_id)
            @assign_to_me = @data.assign_to_me(user_id)
            @assign_by_me = @data.assign_by_me(user_id)
            @my_todo      = @data.my_todo(user_id)
            @following    = @data.following(user_id)
        else
            render nothing: true
        end
        # byebug
        # SnapshortNotifier.daily_snapshort('user@example.com', 'Daily Snapshort', @result).deliver
    end
end