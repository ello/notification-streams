# frozen_string_literal: true

class AddOriginatingUserIdToNotifications < ActiveRecord::Migration[5.0]
  def change
    add_column :notifications, :originating_user_id, :integer, index: true, null: false # # rubocop:disable Rails/NotNullColumn
  end
end
