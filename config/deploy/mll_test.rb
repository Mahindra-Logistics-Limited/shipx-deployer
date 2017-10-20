set :branch, "mll"
set :domain, "10.175.20.69"

set :application, "shipx_test"
set :deploy_to, "/data/shipx_test"

set :rvm_type, :system
set :rvm_ruby_version, "ruby-1.9.3-p547"
set :rvm_custom_path, '/usr/share/rvm'
set :delayed_threads, 2

set :bundle_path, lambda { File.join(deploy_to, "bundle") }

set :rails_env, "testing"
role :web, %w{shipx@10.175.20.69}
role :app, %w{shipx@10.175.20.69}
role :db,  %w{shipx@10.175.20.69}, primary: true

namespace :symlink do
  task :assets_workaround do
    on roles(:web) do
      #hack for assets
      execute "rm -R #{release_path}/public/assets"
      execute "ln -s #{deploy_to}/assets #{release_path}/public/assets"
    end
  end
end

before 'symlink:defaults', "symlink:assets_workaround"
