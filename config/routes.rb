Geigercrowd::Application.routes.draw do

  devise_for :users

  resources :data_types
  resources :locations

  match "samples" => "samples#find", as: :find_samples, via: :post

  resources :users do
    resources :instruments do
      resources :samples
    end
  end

  resources :sources, :as => 'data_sources' do
    resources :instruments do
      resources :samples
    end
  end

  root :to => "welcome#index"

  match "instruments" => "instruments#list", as: :instruments
  match "samples" => "samples#search", as: :samples, via: :get

  match "samples" => "samples#find", as: :samples, via: :post

  match "about" => "welcome#about"

  match "api" => "welcome#api"
  match "api/public" => "welcome#api_public"
  match "api/private" => "welcome#api_private"

  # catch every page and render 404
  match '*a', :to => 'application#routing'
end
