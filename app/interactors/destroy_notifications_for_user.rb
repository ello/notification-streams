class DestroyNotificationsForUser
  include Interactor

  def call
    scope = Notification.where(user_id: context.user_id)
    context.fail! unless scope.delete_all
  end
end
