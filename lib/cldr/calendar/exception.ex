defmodule Cldr.IncompatibleCalendarError do
  @moduledoc """
  Exception raised when an attempt is made to use a two incompatible
  calendars.

  """
  defexception [:message]

  def exception(message) do
    %__MODULE__{message: message}
  end
end
