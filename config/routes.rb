Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :users, only: %i[index show create]
      resources :tags,  only: %i[index create update destroy]

      resources :occurrences, only: %i[index]

      resources :tasks, only: %i[index show create update destroy] do
        resources :tags, only: %i[create destroy], controller: "task_tags"
        patch "occurrences/:original_date", to: "task_occurrences#update", constraints: { original_date: /\d{4}-\d{2}-\d{2}/ }
      end
    end
  end
end