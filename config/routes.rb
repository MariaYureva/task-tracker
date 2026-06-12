Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :users, only: %i[index show create]
      resources :tags,  only: %i[index create update destroy]

      resources :occurrences, only: %i[index]

      resources :tasks, only: %i[index show create update destroy] do
        resources :tags, only: %i[create destroy], controller: "task_tags"
      end
    end
  end
end