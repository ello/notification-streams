# frozen_string_literal: true

class AddIndexOnOriginatingUserIdToNotifications < ActiveRecord::Migration[5.0]
  disable_ddl_transaction!

  def change
    add_index :notifications, :originating_user_id, algorithm: :concurrently
  end
end
