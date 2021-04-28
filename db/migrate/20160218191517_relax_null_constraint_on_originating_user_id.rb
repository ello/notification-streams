# frozen_string_literal: true

class RelaxNullConstraintOnOriginatingUserId < ActiveRecord::Migration[5.0]
  def change
    change_column_null :notifications, :originating_user_id, true
  end
end
