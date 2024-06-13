import Config

config :logger, level: :info

case Mix.env() do
  "dev" -> import_config "dev.exs"
  _ -> nil
end
