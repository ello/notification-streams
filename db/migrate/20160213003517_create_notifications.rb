# frozen_string_literal: true

class CreateNotifications < ActiveRecord::Migration[5.0]
  def change
    create_table :notifications do |t|
      t.integer :user_id
      t.integer :subject_id
      t.string :subject_type
      t.datetime :created_at
      t.string :kind

      t.timestamps
    end

    add_index :notifications, %i[subject_id subject_type],
              name: :index_notifications_on_subject_id_and_subject_type, using: :btree
    add_index :notifications, %i[user_id created_at subject_id subject_type kind],
              name: :covering_index_on_notifications, unique: true, using: :btree
  end
end
