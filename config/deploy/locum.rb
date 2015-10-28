role :app, %w(hosting_avpp@calcium.locum.ru)
role :web, %w(hosting_avpp@calcium.locum.ru)
role :db, %w(hosting_avpp@calcium.locum.ru)

set :ssh_options, forward_agent: true
set :rails_env, :production
