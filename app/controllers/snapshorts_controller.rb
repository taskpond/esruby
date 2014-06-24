require 'mathn'

class SnapshortsController < ApplicationController

    def index
        @users = Hashie::Mash.new User.new(@users).extend(UserRepresenter).to_hash
    end

    def show
    end

    def daily

        user_id       = params[:user_id].present? ? params[:user_id] : 141
        @result       = Es.new
        @result       = @result.fetch_data(user_id)

        # SnapshortNotifier.daily_snapshort('user@example.com', 'Daily Snapshort', @result).deliver

        return render layout: nil
    end
end