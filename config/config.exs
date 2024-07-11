import Config

config :logger, level: :info
config :tavern, port: String.to_integer(System.get_env("PORT", "4305"))
case Mix.env() do
  "dev" -> import_config "dev.exs"
  _ -> nil
end
