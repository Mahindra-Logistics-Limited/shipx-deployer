set :branch, "mll_deploy"
set :domain, "10.175.16.68"

set :application, "shipx"
set :deploy_to, "/shared/shipx2/app"

set :rvm_type, :system
set :rvm_ruby_version, "ruby-2.3.7"
set :rvm_custom_path, '/usr/share/rvm'
set :delayed_threads, 7

set :bundle_path, lambda { File.join(deploy_to, "bundle") }

set :rails_env, "production"
role :web, %w{shipx@10.175.16.76 shipx@10.175.20.68 shipx@10.175.16.75}
role :app, %w{shipx@10.175.17.4}
role :db,  %w{shipx@10.175.17.4}, primary: true

namespace :symlink do
  task :assets_workaround do
    on roles(:web) do
      #hack for assets
      execute "rm -R #{release_path}/public/assets"
      execute "ln -s #{deploy_to}/assets #{release_path}/public/assets"
    end
  end
end

namespace :symlink do
  task :pids_workaround do
    on roles(:web, :app) do
      #hack for pids
      execute "rm -R #{release_path}/tmp/pids"
      execute "mkdir -p #{deploy_to}/pids"
      execute "ln -s #{deploy_to}/pids #{release_path}/tmp/pids"

      execute "rm #{release_path}/log"
      execute "mkdir -p #{deploy_to}/log"
      execute "ln -s #{deploy_to}/log #{release_path}/log"
    end
  end
end

before 'symlink:defaults', "symlink:assets_workaround"
after  'symlink:defaults', "symlink:pids_workaround"
