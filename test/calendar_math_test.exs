defmodule Cldr.Calendar.Math.Test do
  use ExUnit.Case, async: true

  test "Adding months defaults to coerce: true" do
    assert Cldr.Calendar.plus(~D[2024-02-29], :months, 12) == ~D[2025-02-28]
    assert Cldr.Calendar.plus(~D[2024-02-29], :months, 12, coerce: false) == {:error, :invalid_date}

    assert Cldr.Calendar.minus(~D[2024-02-29], :months, 12) == ~D[2023-02-28]
    assert Cldr.Calendar.minus(~D[2024-02-29], :months, 12, coerce: false) == {:error, :invalid_date}
  end

  test "Adding years defaults to coerce: true" do
    assert Cldr.Calendar.plus(~D[2024-02-29], :years, 1) == ~D[2025-02-28]
    assert Cldr.Calendar.plus(~D[2024-02-29], :years, 1, coerce: false) == {:error, :invalid_date}

    assert Cldr.Calendar.minus(~D[2024-02-29], :years, 1) == ~D[2023-02-28]
    assert Cldr.Calendar.minus(~D[2024-02-29], :years, 1, coerce: false) == {:error, :invalid_date}
  end

end