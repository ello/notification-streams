class DestroyNotificationsForSubject
  include Interactor

  def call
    scope = Notification.where(subject_type: context.subject_type,
                               subject_id: context.subject_id)
    context.fail! unless scope.delete_all
  end
end
