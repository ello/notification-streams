class NotificationsColumnsShouldNotBeNullable < ActiveRecord::Migration[5.0]
  def change
    change_column_null :notifications, :user_id, false
    change_column_null :notifications, :subject_id, false
    change_column_null :notifications, :subject_type, false
    change_column_null :notifications, :kind, false
  end
end
