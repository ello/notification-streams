class TrimNotificationsForUser
  include Interactor

  def call
    scope = Notification.
      for_user(context.user_id).
      for_category(context.category).
      offset_by(context.user_id, context.keep)
    context.fail! unless scope.delete_all
  end
end
