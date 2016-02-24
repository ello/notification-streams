class TrimNotificationsForUser
  include Interactor

  def call
    (Notification::CATEGORIES.keys - [ :all ]).each do |category|
      scope = Notification.for_notification_stream(context.user_id,
                                                   category,
                                                   [],
                                                   nil,
                                                   context.keep)

      result = Notification.for_user(context.user_id).for_category(category).where(<<-EOF).delete_all
       (#{Notification::SELECTED_FIELDS * ','}) NOT IN (#{scope.to_sql})
      EOF
      Rails.logger.info "Trimming #{category} for #{context.user_id}: #{result}"
    end
  end
end
