class UserId < ActiveRecord::Migration
  def change
    create_table :users do |t|
        t.integer :ids
    end
  end
end
