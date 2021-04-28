# frozen_string_literal: true

class DestroyNotificationsForUser
  include Interactor

  def call
    user_scope = Notification.where(user_id: context.user_id)
    originating_scope = Notification.where(originating_user_id: context.user_id)
    context.fail! unless user_scope.delete_all && originating_scope.delete_all
  end
end
