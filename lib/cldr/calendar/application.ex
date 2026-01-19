defmodule Cldr.Calendar.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      Cldr.Calendar.Compiler
    ]

    Supervisor.start_link(children, [strategy: :one_for_one, name: __MODULE__])
  end
end
