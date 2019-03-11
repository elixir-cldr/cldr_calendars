# CldrCalendars

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `cldr_calendars` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_cldr_calendars, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/cldr_calendars](https://hexdocs.pm/cldr_calendars).

### To Do

* [ ] Cldr.Calendar.Week is a factory calendar and all functions should take options.  The options will be passed by generated calendars.

* [ ] Generate Cldr.Calendar.ISO.Week and Cldr.Calendar.NRF as examples of week based calendars.  NRF is defined as min_days 5, first_day 7.

* [ ] Add variable year support: (first/last/nearest day_of_week, month).  Combined with min_days we get a lot of flexibility.  An ISO week calendar is defined as "first Monday of January, min 4 days"