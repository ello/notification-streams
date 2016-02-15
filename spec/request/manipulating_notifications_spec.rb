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

  describe 'retrieving notifications for a user', freeze_time: true do
    let(:response_json) { JSON.parse(response.body) }
    let!(:notification1) { CreateNotificationForUser.call(user_id: 1,
                                                          kind: Notification::COMMENT_NOTIFICATION_KIND,
                                                          subject_id: 10,
                                                          subject_type: 'Post',
                                                          created_at: 2.days.ago) }
    let!(:notification2) { CreateNotificationForUser.call(user_id: 1,
                                                          kind: Notification::LOVE_NOTIFICATION_KIND,
                                                          subject_id: 11,
                                                          subject_type: 'Post',
                                                          created_at: 1.day.ago) }
    describe 'without any parameters' do
      before do
        get '/api/v1/users/1/notifications'
      end

      it 'returns notifications in reverse chronological order' do
        expect(response.status).to eq(200)
        expect(response_json).to eq([
          { 'user_id' => 1,
            'subject_id' => 11,
            'subject_type'=> 'Post',
            'kind' => 'love_notification',
            'created_at' => 1.day.ago.as_json },
          { 'user_id' => 1,
            'subject_id' => 10,
            'subject_type' => 'Post',
            'kind' => 'comment_notification',
            'created_at' => 2.days.ago.as_json }
        ])
      end
    end

    describe 'filtering by category' do
      before do
        get '/api/v1/users/1/notifications', params: { category: 'loves' }
      end

      it 'only returns notifications in the specified category' do
        expect(response.status).to eq(200)
        expect(response_json).to eq([
          { 'user_id' => 1,
            'subject_id' => 11,
            'subject_type'=> 'Post',
            'kind' => 'love_notification',
            'created_at' => 1.day.ago.as_json }
        ])
      end
    end

    describe 'paginating by timestamp' do
      before do
        get '/api/v1/users/1/notifications', params: { before: 1.day.ago.as_json }
      end

      it 'only returns notifications before the specified timestamp' do
        expect(response.status).to eq(200)
        expect(response_json).to eq([
          { 'user_id' => 1,
            'subject_id' => 10,
            'subject_type' => 'Post',
            'kind' => 'comment_notification',
            'created_at' => 2.days.ago.as_json }
        ])
      end
    end

    describe 'limiting results' do
      before do
        get '/api/v1/users/1/notifications', params: { limit: 1 }
      end

      it 'only returns the specified number of results' do
        expect(response.status).to eq(200)
        expect(response_json).to eq([
          { 'user_id' => 1,
            'subject_id' => 11,
            'subject_type'=> 'Post',
            'kind' => 'love_notification',
            'created_at' => 1.day.ago.as_json }
        ])
      end
    end

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
