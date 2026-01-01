defmodule Cldr.Calendar.Compiler do
  @moduledoc false

  use GenServer
  alias Cldr.Calendar.Config

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def create_calendar(calendar_module, calendar_type, config) do
    config = Keyword.put(config, :calendar, calendar_module)
    structured_config = Config.extract_options(config)

    with {:ok, config} <- Config.validate_config(structured_config, calendar_type) do
      calendar_type =
        calendar_type
        |> to_string
        |> String.capitalize()

      config =
        config
        |> Map.from_struct()
        |> Map.to_list()

      contents =
        quote do
          use unquote(Module.concat(Cldr.Calendar.Base, calendar_type)),
              unquote(Macro.escape(config))
        end

      GenServer.call(__MODULE__, {
        :compile, calendar_module, contents, Macro.Env.location(__ENV__)
      })
    end
  end

  ## Callbacks

  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_call({:compile, module, contents, env}, _from, state) do
    cond do
      Code.ensure_loaded?(module) ->
        {:reply, {:ok, module}, state}

      {:module, module, _, :ok} = Module.create(module, contents, env) ->
        {:reply, {:ok, module}, state}
    end
  end

end