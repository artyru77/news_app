Rails.application.routes.draw do
  root 'news#show'
  get '/', to: 'news#show', as: :show_news
  post :admin, to: 'news#create', as: :create_custom_news
  patch '/update/:id', to: 'news#update', as: :update_custom_news
  get :admin, to: 'news#admin'
end
