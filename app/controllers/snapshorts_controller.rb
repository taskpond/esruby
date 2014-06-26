require 'mathn'

class SnapshortsController < ApplicationController

    def index
        @users = Hashie::Mash.new User.new(@users).extend(UserRepresenter).to_hash
    end

    def show
    end

    def daily
        @from       = '2014-04-30T23:59:59'.to_datetime
        user_id       = params[:user_id].present? ? params[:user_id] : 141
        @data         = Es.new
        @result       = @data.fetch_data(user_id)
        @assign_to_me = @data.assign_to_me(user_id)
        # byebug
        # SnapshortNotifier.daily_snapshort('user@example.com', 'Daily Snapshort', @result).deliver

        return render layout: nil
    end
end