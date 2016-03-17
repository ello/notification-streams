class CreateNotificationForUser
  include Interactor

  def call
    begin
      context.notification = Notification.create(context.to_h)
      if context.notification.persisted?
        TrimQueue.push(context.user_id)
      else
        context.fail!
      end
    rescue ActiveRecord::RecordNotUnique
      # The record is already there so just return it
      context.notification = Notification.where(context.to_h).first
    end
  end
end
