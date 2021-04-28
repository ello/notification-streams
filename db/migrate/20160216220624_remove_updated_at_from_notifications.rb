# frozen_string_literal: true

class RemoveUpdatedAtFromNotifications < ActiveRecord::Migration[5.0]
  def change
    remove_column :notifications, :updated_at, :datetime
  end
end
