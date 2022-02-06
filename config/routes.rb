Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'application#redirect_to_welcome' 
  get '/welcome' => 'pages#index'
  
  # These routes are for showing users a login form, logging them in, and logging them out:
  get '/login' => 'sessions#new'
  post '/login' => 'sessions#create'
  get '/logout' => 'sessions#destroy'
  
  # These routes will be for signup. The first renders a form in the browser, the second will 
  # receive the form and create a user in our database using the data given to us by the user:
  resources :users
  get '/signup' => 'users#new'
  post '/users' => 'users#create'
  
  # This route is for showing users their dashboard:
  get '/dashboard' => 'dashboards#show'
  post '/dashboard' => 'dashboards#show'
  post 'filter_dids', to: 'dashboards#filter_dids', as: :filter_dids
  post 'reassign_dids', to: 'dashboards#reassign_dids', as: :reassign_dids
  
  # These routes are used for email validation links:
  get '/emailconfirmation' => 'email_confirmations#update'
  get '/sendemailverify' => 'email_confirmations#create'
  
  # These routes are used for forgetten password resets:
  get 'password_resets/new'
  get '/passwordreset' => 'password_resets#edit'
  post '/passwordreset' => 'password_resets#update'
  get '/requestreset' => 'password_resets#new'
  post '/requestreset' => 'password_resets#create'
  
  resources :verticals
  
  resources :sources
  
  resources :funnels
  put 'funnel_buy_dids', to: 'funnels#buy_dids', as: :funnel_buy_dids
  
  resources :campaigns do
		member do
			get :contact_history
		end
	end
  
  get '/contacts' => 'contacts#index'
  put '/contacts' => 'contacts#update'
  
  get '/backoffice' => 'backoffice#index'
  
  resources :globals, controller: 'backoffice'
	
	patch '/backoffice' => 'backoffice#update'
	
	resources :backoffice
  
  resources :charges
	
	resources :ivrs
end
