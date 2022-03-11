use Mix.Releases.Config, default_environment: :prod
  
environment :prod do
  set(include_erts: true)
  set(include_src: false)
  set(cookie: :todo_ex)
end
  
release :todo_ex do
 set(version: current_version(:todo_ex))
end
