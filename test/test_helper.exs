ExUnit.start()

# Don't run tests unless they are version
# compatible

if Version.compare(System.version(), "1.10.0-dev") == :lt do
  ExUnit.configure(exclude: [elixir_1_10: true])
else
  ExUnit.configure(exclude: [elixir_1_9: true])
end
