class NotificationsController < ApplicationController

  def create
    result = CreateNotificationForUser.call(notification_params)

    if result.success?
      head :created
    else
      head :unprocessable_entity
    end
  end

  def destroy
    result = if params[:user_id]
               DestroyNotificationsForUser.call(notification_params)
             else
               DestroyNotificationsForSubject.call(notification_params)
             end
    if result.success?
      head :accepted
    else
      head :unprocessable_entity
    end
  end

  def show
    render json: Notification.for_notification_stream(params[:user_id],
                                                      params[:category],
                                                      excluded_originating_user_ids,
                                                      params[:before],
                                                      params[:limit]
                                                     ).to_json
  end

  private

  def excluded_originating_user_ids
    (params[:exclude_originating_user_ids] || '').split(',').map(&:to_i)
  end

  def notification_params
    params.permit(:user_id,
                  :subject_id,
                  :subject_type,
                  :kind,
                  :created_at,
                  :originating_user_id)
  end

end
