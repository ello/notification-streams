# frozen_string_literal: true

Rails.application.routes.draw do
  scope :api do
    scope :v1 do
      resources :users, only: [] do
        resource :notifications, only: %i[show create destroy]
      end
      resource :notifications, only: [:destroy]
    end
  end
end
