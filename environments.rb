configure :development do
 set :database, 'sqlite3:db/dev.db'
 set :show_exceptions, true
end

configure :test do
  set :database, 'sqlite3:db/test.db'
  set :show_exceptions, true
end

configure :production do
  db = URL.parse(ENV['DATABASE_URL'] || 'postgres://wycgpcwmjtajrd:3I4DIQaACUy-K_a-Dx3Jk8daNA@ec2-23-21-76-246.compute-1.amazonaws.com:5432/d4gj83jiope31j')

  ActiveRecord::Base.establish_connection(
    adpater: db.scheme == 'postgres' ? 'postgresql' : db.scheme,
    host: db.host,
    username: db.user,
    password: db.password,
    database: db.path[1..-1],
    encoding: 'utf8'
  )
end
