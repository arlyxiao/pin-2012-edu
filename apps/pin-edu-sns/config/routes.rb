MindpinEduSns::Application.routes.draw do

  root :to => 'index#index'
  
  # ------------- 媒体文件
  resources :media_files do
    collection do
      get :new_psu
      post :create_by_edu
      post :encode_complete
      get :lifei_list
    end
    member do
      get :lifei_info
    end
  end
  
  # --- 用户
  resources :users
  
  # --- 待办事项
  resources :todos do
    member do
      put :do_complete
    end
  end
  # --- 作业
  resources :homeworks do
    collection do
      post :create_teacher_attachement
    end
    
    member do
      get :download_teacher_zip
    end
  end
  get 'homeworks/:id/:download_teacher_zip' => 'homeworks#download_teacher_zip'
  # 老师查看某一学生作业路由
  get 'homeworks/:homework_id/student/:user_id' => 'homeworks#student'

  resources :homeworks, :student
end
