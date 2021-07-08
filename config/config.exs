import Config

config :app, ecto_repos: [Storage.Repos.App]
config :app, Storage.Repos.App,
  database: System.get_env("repo_app_database") || "app_repo",
  username: System.get_env("repo_app_username") || "ecto",
  password: System.get_env("repo_app_password") || "ecto",
  hostname: System.get_env("repo_app_hostname") || "localhost",
  priv: "lib/storage/"


config :app, Connections.Http.Authenticator,
  issuer: "app",
  secret_key: "zq3KZSXZmaimKLsWaC8eTpHkQY5HixbSx83ODtF4w7mf0xiO5wnN8x9fr3F0ZSFH"


config :app, secret_key_base: "bGuictyMHe9QIDywoUmfjojuvImP8wInQXQXuaLuHcwQTMs2R32wh6HQkA5PWkVR"
config :app, session_signing_salt: "T/6rc89M"
