require 'rails_helper'

describe TrimNotificationsForUser do

  before do
    1.upto(5) do |i|
      CreateNotificationForUser.call(user_id: 1,
                                     kind: Notification::COMMENT_MENTION_NOTIFICATION_KIND,
                                     subject_id: i,
                                     subject_type: 'Post',
                                     originating_user_id: 1,
                                     created_at: i.hours.ago)
    end

    1.upto(5) do |i|
      CreateNotificationForUser.call(user_id: 1,
                                     kind: Notification::LOVE_NOTIFICATION_KIND,
                                     subject_id: i,
                                     subject_type: 'Love',
                                     originating_user_id: 1,
                                     created_at: i.hours.ago)
    end
  end

  it 'removes notifications beyond a specified keep threshold' do
    TrimNotificationsForUser.call(user_id: 1,
                                  category: :all,
                                  keep: 5)
    expect(Notification.for_user(1).count).to eq(5)
  end

  it 'ignores notifications outside the specified category' do
    TrimNotificationsForUser.call(user_id: 1,
                                  category: :loves,
                                  keep: 1)
    expect(Notification.for_user(1).count).to eq(6)
    expect(Notification.for_user(1).for_category(:loves).count).to eq(1)
  end
end
