namespace :delayed_job do
  def args(stop_or_start=:start)
    threads = fetch(:delayed_threads, 1)
    stop_or_start == :stop ? "-n #{threads + 10}" : "-n #{threads}"
  end

  desc "Start delayed_job process"
  task :start do
    on roles(:app) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :bundle, :exec, :'script/delayed_job', args(:stop), :stop
          execute "sleep 5"
          execute :bundle, :exec, :'script/delayed_job', args(:start), :start
        end
      end
    end
  end

  desc "Stop delayed_job process"
  task :stop do
    on roles(:app) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :bundle, :exec, :'script/delayed_job', args(:stop), :stop
        end
      end
    end
  end

  desc "Restart delayed_job process"
  task :restart do
    on roles(:app) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :bundle, :exec, :'script/delayed_job', args(:stop), :stop
          execute "sleep 5"
          execute :bundle, :exec, :'script/delayed_job', args(:start), :start
        end
      end
    end
  end
end

