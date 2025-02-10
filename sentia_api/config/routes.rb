Rails.application.routes.draw do
  resources :people, only: %i[index] do
    post :import, on: :collection
  end
end
