namespace :whenever do
  desc "Update the crontab file"
  task :update_crontab do
    on roles(:app) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :bundle, :exec, :whenever, "--update-crontab #{fetch :whenever_identifier} --set #{fetch :whenever_variables}"
        end
      end
      #execute "cd #{release_path} && bundle exec whenever --update-crontab #{application} --set environment=#{rails_env}"
    end
  end

  desc "Clear application's crontab entries using Whenever"
  task :clear_crontab do
    on roles(:app) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :bundle, :exec, :whenever, "--clear-crontab #{fetch :whenever_identifier}""
        end
      end
    end
  end
end

