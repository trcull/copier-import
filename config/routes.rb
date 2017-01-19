RetentionfactoryEngine::Application.routes.draw do
  root 'splash#index'

  devise_for :users, :controllers => {:sessions => 'sessions', :registrations=>'registrations'} #override the default devise controller with our own in app/controllers/sessions_controller

  resources :organizations, only: [:edit, :update] do
    member do
      get 'confirm' => 'organizations#confirm'
    end
  end
  get 'organization/:organization_id/select' => 'organizations#select'
  
  get 'blank' => 'application#blank'
  get 'welcome' => 'invoice_import#xerox_invoice'
  get 'support' => 'invoice_import#xerox_invoice'  
  
  
  
  namespace :admin do
    resources :users
    get 'configuration' => 'configuration#index'
  end
  
  namespace :fb do
    match 'accounts/connect_account' => 'accounts#connect_account', :via=>[:get, :post]
    match 'oauth_callback' => 'accounts#oauth_callback', :via=>[:get, :post]
    
    match 'xerox_invoice' => 'invoice_import#xerox_invoice' , :via=>[:get, :post]
    match 'invoice_import/copier/:id/edit' => 'invoice_import#edit_copier' , :via=>[:get, :post]
    match 'invoice_import/copier/:id' => 'invoice_import#delete_copier', :via=>:delete 
    match 'invoice_import/copier/:id' => 'invoice_import#save_copier', :via=>:post 
    match 'invoice_import/add_copier' => 'invoice_import#add_copier' , :via=>[:get, :post]
    match 'invoice_import/xerox_upload' => 'invoice_import#xerox_upload' , :via=>[:get, :post]
    match 'invoice_import/xerox_confirm' => 'invoice_import#xerox_confirm' , :via=>[:get, :post]
    match 'invoice_import/sales_by_date' => 'invoice_import#sales_by_date', :via=>[:get, :post]
  end
    
  resources :alerts do
    member do
      post 'acknowledge'
    end
    collection do
      get 'notifications'
    end
  end  
  
end
