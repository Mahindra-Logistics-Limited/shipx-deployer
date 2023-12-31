# config valid only for current version of Capistrano
lock "3.9.0"

set :application, "shipx"
set :repo_url, "git@bitbucket.org:shipx/shipx.git"
set :branch, "master"
set :deploy_to, "/data/shipx"

set :rvm_type, :system
set :rvm_ruby_version, 'ruby-1.9.3-p547'      # Defaults to: 'default'

set :rails_assets_groups, 'assets'

set :keep_releases, 10
set :delayed_threads, 1

set :whenever_variables,   ->{ "environment=#{fetch :rails_env}" }
set :whenever_identifier,  ->{ fetch :application }

set :bundle_without,  [:development]

namespace :symlink do
  desc "Symlinks yml files from shared to new release folder"
  task :defaults do
    on roles(:app, :web) do 
    # new directories
      execute "mkdir -p #{release_path}/misc/"
      execute "mkdir -p #{release_path}/public/flash"
      execute "ln -s #{shared_path}/system #{release_path}/public/system"
      execute "ln -s #{shared_path}/log #{release_path}/log"

      execute "mkdir -p #{shared_path}/pids"
      execute "mkdir -p #{release_path}/tmp"
      execute "ln -s #{shared_path}/pids #{release_path}/tmp/pids"
  
      # Main configuration files
      execute "ln -s #{shared_path}/database.yml #{release_path}/config/database.yml"
      execute "ln -s #{shared_path}/mailer.yml #{release_path}/config/mailer.yml"
      execute "ln -s #{shared_path}/sms.yml #{release_path}/config/sms.yml"
      execute "ln -s #{shared_path}/cache.yml #{release_path}/config/cache.yml"
      execute "ln -s #{shared_path}/sms_params.yml #{release_path}/config/sms_params.yml"
      execute "ln -s #{shared_path}/gps_params.yml #{release_path}/config/gps_params.yml"
      execute "ln -s #{shared_path}/e_invoice_params.yml #{release_path}/config/e_invoice_params.yml"
      execute "ln -s #{shared_path}/company_google_api_key.yml #{release_path}/config/company_google_api_key.yml"
      execute "ln -s #{shared_path}/auto_track_params.yml #{release_path}/config/auto_track_params.yml"
      execute "ln -s #{shared_path}/route_planning_params.yml #{release_path}/config/route_planning_params.yml"
      execute "ln -s #{shared_path}/extensions.yml #{release_path}/config/extensions.yml"
      execute "ln -s #{shared_path}/theme_extensions.yml #{release_path}/config/theme_extensions.yml"
      execute "ln -s #{shared_path}/extended #{release_path}/config/extended"
      execute "ln -s #{shared_path}/.ruby-version #{release_path}/.ruby-version"
      execute "ln -s #{shared_path}/eway_bill_gsp.yml #{release_path}/config/eway_bill_gsp.yml"
      execute "ln -s #{shared_path}/ptl_gps_params.yml #{release_path}/config/ptl_gps_params.yml"
  
      # shared folders
      execute "ln -s #{shared_path}/documents #{release_path}/public/documents"
      execute "ln -s #{shared_path}/barcodes #{release_path}/public/barcodes"
      execute "ln -s #{shared_path}/shipx_documents #{release_path}/public/shipx_documents"
      execute "ln -s #{shared_path}/blog #{release_path}/public/blog"
  
      # for file uploads
      execute "ln -s #{shared_path}/file_uploaded #{release_path}/misc/file_uploaded"
      execute "ln -s #{shared_path}/file_upload_error #{release_path}/public/file_upload_error"
      execute "ln -s #{shared_path}/report_attachments #{release_path}/public/report_attachments"
  
      # for apks
      execute "ln -s #{shared_path}/apks #{release_path}/public/apks"
  
      # for custom config, theme and custom templates
      execute "ln -s #{shared_path}/shipx_config #{release_path}/config/shipx_config"
      execute "ln -s #{shared_path}/theme #{release_path}/public/theme"
      execute "ln -s #{shared_path}/custom_templates #{release_path}/app/custom_templates"
      execute "ln -s #{shared_path}/custom_template_views #{release_path}/app/views/custom_template_views"
      execute "ln -s #{shared_path}/custom_extensions #{release_path}/app/custom_extensions"
      execute "ln -s #{shared_path}/custom_menu.yaml #{release_path}/config/custom_menu.yaml"
      execute "ln -sf #{shared_path}/geokit_keys.rb #{release_path}/config/initializers/geokit_keys.rb"

      #for monkey patches
      execute "ln -s #{shared_path}/patches #{release_path}/patches"


    end
  end

end

namespace :deploy do
  desc "Restart Application"
  task :restart do
    on roles(:web) do
      execute "touch #{current_path}/tmp/restart.txt"
    end
  end

  desc "Start Application"
  task :start do
    on roles(:web) do
      #do nothing
    end
  end

  desc "Stop Application"
  task :stop do
    on roles(:web) do
      #do nothing
    end
  end
end

before 'bundler:install', "symlink:defaults"

after "deploy:updated",  "whenever:update_crontab"
after "deploy:reverted", "whenever:update_crontab"

after 'deploy:published', 'deploy:restart'

after "deploy:restart", "delayed_job:restart"
after "deploy:start", "delayed_job:start"
after "deploy:stop", "delayed_job:stop"
