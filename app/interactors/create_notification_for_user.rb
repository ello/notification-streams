class CreateNotificationForUser
  include Interactor

  def call
    notification = Notification.create(context.to_h)

    if notification.persisted?
      context.notification = notification
    else
      context.fail!
    end
  end
end
