class CreateNotificationForUser
  include Interactor

  def call
    begin
      notification = Notification.create(context.to_h)
    rescue ActiveRecord::RecordNotUnique
      # The record is already there so just return it
      notification = Notification.where(context.to_h).first
    end

    context.notification = notification
    context.fail! unless notification.persisted?
  end
end
