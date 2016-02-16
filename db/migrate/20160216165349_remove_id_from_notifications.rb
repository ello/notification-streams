class RemoveIdFromNotifications < ActiveRecord::Migration[5.0]
  def change
    remove_column :notifications, :id
  end
end
