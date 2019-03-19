defmodule Cldr.Calendar.FiscalYear do

  @fiscal_year_data "./priv/fiscal_years_by_territory.csv"
  @fiscal_year_by_territory @fiscal_year_data
    |> File.read!
    |> NimbleCSV.RFC4180.parse_string
    |> Enum.map(fn
      [_, "", _, _, _month, _day, _min_days, _] ->
        nil
      [_, territory, _, "Cldr.Calendar.Gregorian" = calendar, month, _day, _min_days, _] ->
        {:ok, territory} = Cldr.validate_territory(territory)
        calendar = Module.concat([calendar])
        month = String.to_integer(month)
        {territory, [calendar: calendar, month: month]}
      _other  ->
        nil
      end)
    |> Enum.reject(&is_nil/1)
    |> Map.new

  @known_fiscal_calendars Map.keys(@fiscal_year_by_territory)

  def territory_fiscal_years do
    @fiscal_year_by_territory
  end

  def known_fiscal_calendars do
    @known_fiscal_calendars
  end

  def calendar_for(territory) do
    with {:ok, territory} <- Cldr.validate_territory(territory),
         territory in known_fiscal_calendars() do
      get_or_create_calendar_for(territory, Map.get(territory_fiscal_years(), territory))
    end
  end

  def get_or_create_calendar_for(territory, config) do
    module = Module.concat(Cldr.Calendar, territory)
    if Code.ensure_loaded?(module) do
      {:ok, module}
    else
      contents = quote do
        use Cldr.Calendar.Base.Month, unquote(config)
      end
      {:module, module, _, :ok} = Module.create(module, contents, Macro.Env.location(__ENV__))
      {:ok, module}
    end
  end
end