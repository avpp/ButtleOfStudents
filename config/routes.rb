Rails.application.routes.draw do
  get 'welcome/index'

  devise_for :users
  resources :users

  get 'users/:id/reset_password' => 'users#reset_password', as: :reset_user_password
  patch 'users/:id/update_password' => 'users#update_password', as: :update_user_password
  
  resources :battles do
    resources :teams do
      post 'assign'=>'teams#assign', as: :assign
      delete 'assign'=>'teams#unassign', as: :unassign
    end
    post 'tasks_list'=>'tasks#tasks_list', as: :tasks_list
    post 'stop'=>'battles#stop', as: :stop
    post 'assign'=>'battles#assign', as: :assign
    get 'manage'=>'battles#manage', as: :manage
    post 'person_raiting'=>'battles#person_raiting', as: :person_raiting
    post 'team_raiting'=>'battles#team_raiting', as: :team_raiting
  end

  post 'tasks/:id/answer'=>'tasks#answer', as: :answer_task
  post 'tasks/:id'=>'tasks#task', as: :task

  resources :task_types

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
