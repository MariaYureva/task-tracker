Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :users, only: %i[index show create]
      resources :tasks, only: %i[index show create update destroy]
    end
  end
end