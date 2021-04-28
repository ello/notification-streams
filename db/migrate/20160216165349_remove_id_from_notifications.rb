# frozen_string_literal: true

class RemoveIdFromNotifications < ActiveRecord::Migration[5.0]
  def change
    remove_column :notifications, :id, :integer
  end
end
