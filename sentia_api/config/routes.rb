Rails.application.routes.draw do
  resources :people, only: %i[index] do
    get :import, on: :collection
  end
end
