# frozen_string_literal: true

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

  end

  it 'removes notifications beyond a specified keep threshold' do
    described_class.call(user_id: 1,
                         keep: 3)
    expect(Notification.for_user(1).count).to eq(3)
  end

  describe 'when notifications exist in multiple categories' do
    before do
      1.upto(5) do |i|
        CreateNotificationForUser.call(user_id: 1,
                                       kind: Notification::LOVE_NOTIFICATION_KIND,
                                       subject_id: i,
                                       subject_type: 'Love',
                                       originating_user_id: 1,
                                       created_at: i.hours.ago)
      end
    end

    it 'keeps the specified number of notifications in each category' do
      described_class.call(user_id: 1,
                           keep: 1)
      expect(Notification.for_user(1).count).to eq(2)
      expect(Notification.for_user(1).for_category(:loves).count).to eq(1)
      expect(Notification.for_user(1).for_category(:mentions).count).to eq(1)
    end
  end
end
