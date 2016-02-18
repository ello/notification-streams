class UpdateCoveringIndexToIncludeOriginatingUserId < ActiveRecord::Migration[5.0]
  def change
    remove_index :notifications, name: 'covering_index_on_notifications'
    add_index :notifications, [ :user_id,
                                :created_at,
                                :subject_id,
                                :subject_type,
                                :kind,
                                :originating_user_id ], name: 'covering_index_on_notifications', unique: true, using: :btree
  end
end
