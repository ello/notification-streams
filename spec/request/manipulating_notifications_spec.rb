require 'rails_helper'

RSpec.describe 'Manipulating notifications via the API', type: :request, freeze_time: true do

  describe 'creating a notification for a user' do
    describe 'when valid parameters are passed' do
      before do
        post '/api/v1/users/1/notifications', params: { subject_id: 10,
                                                        subject_type: 'Post',
                                                        kind: Notification::COMMENT_MENTION_NOTIFICATION_KIND,
                                                        created_at: Time.zone.now }
      end

      let(:notification) { Notification.first }

      it 'creates a new Notification object' do
        expect(Notification.count).to eq(1)
        expect(notification.subject_id).to eq(10)
        expect(notification.subject_type).to eq('Post')
        expect(notification.kind).to eq(Notification::COMMENT_MENTION_NOTIFICATION_KIND)
        expect(notification.created_at).to eq(Time.zone.now)
      end

      it 'responds with a 201 and an empty body' do
        expect(response.status).to eq(201)
        expect(response.body).to be_empty
      end
    end

    describe 'when invalid parameters are passed' do
      before do
        post '/api/v1/users/1/notifications', params: { }
      end

      it 'does not create any Notification objects' do
        expect(Notification.count).to eq(0)
      end

      it 'responds with a 422 and an empty body' do
        expect(response.status).to eq(422)
        expect(response.body).to be_empty
      end
    end
  end

  describe 'retrieving notifications for a user' do
  end

  describe 'deleting notifications for a user' do
    let!(:notification) { CreateNotificationForUser.call(user_id: 1,
                                                         kind: Notification::COMMENT_MENTION_NOTIFICATION_KIND,
                                                         subject_id: 10,
                                                         subject_type: 'Post',
                                                         created_at: Time.zone.now) }

    before do
      delete '/api/v1/users/1/notifications'
    end

    it 'removes all notifications for that user' do
      expect(Notification.where(user_id: 1).count).to eq(0)
    end

    it 'responds with a 202 and an empty body' do
      expect(response.status).to eq(202)
      expect(response.body).to be_empty
    end
  end

  describe 'deleting notifications for a subject' do
    let!(:notification) { CreateNotificationForUser.call(user_id: 1,
                                                         kind: Notification::COMMENT_MENTION_NOTIFICATION_KIND,
                                                         subject_id: 10,
                                                         subject_type: 'Post',
                                                         created_at: Time.zone.now) }

    before do
      delete '/api/v1/notifications', params: { subject_id: 10, subject_type: 'Post' }
    end

    it 'removes all notifications for that subject id/type' do
      expect(Notification.where(subject_id: 10, subject_type: 'Post').count).to eq(0)
    end

    it 'responds with a 202 and an empty body' do
      expect(response.status).to eq(202)
      expect(response.body).to be_empty
    end
  end
end
