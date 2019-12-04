defmodule Day1 do
  def test_fuel_case(mass, expected, fun) do
    (if fun.(mass) == expected do
       "PASS"
     else
       "FAIL"
     end <>
       ": fuel required for mass #{mass} should be #{expected}, and it is #{fun.(mass)}")
    |> IO.puts()
  end

  def fuel_required_for_module(mass) do
    floor(mass / 3) - 2
  end

  # Includes the fuel required for the fuel.
  def total_fuel_required_for_module(mass) do
    Stream.unfold(mass, fn
      x when x > 0 -> {x, fuel_required_for_module(x)}
      _ -> nil
    end)
    # The initial mass is not itself fuel
    |> Stream.drop(1)
    |> Enum.reduce(&+/2)
  end

  def run() do
    Day1.test_fuel_case(12, 2, &Day1.fuel_required_for_module/1)
    Day1.test_fuel_case(14, 2, &Day1.fuel_required_for_module/1)
    Day1.test_fuel_case(1969, 654, &Day1.fuel_required_for_module/1)
    Day1.test_fuel_case(100_756, 33583, &Day1.fuel_required_for_module/1)

    IO.puts("dir #{Application.app_dir(:advent2019, "priv/day1.txt")}")

    modules =
      Advent2019.input_lines(1)
      |> Stream.map(&String.to_integer/1)

    total_fuel_required =
      Enum.reduce(modules, 0, fn module, acc -> Day1.fuel_required_for_module(module) + acc end)

    IO.puts("Part 1: Total fuel required: #{total_fuel_required}")

    Day1.test_fuel_case(12, 2, &Day1.total_fuel_required_for_module/1)
    Day1.test_fuel_case(1969, 966, &Day1.total_fuel_required_for_module/1)
    Day1.test_fuel_case(100_756, 50346, &Day1.total_fuel_required_for_module/1)

    total_total_fuel_required =
      Enum.reduce(modules, 0, fn module, acc ->
        Day1.total_fuel_required_for_module(module) + acc
      end)

    IO.puts("Part 2: Total fuel required: #{total_total_fuel_required}")
  end
end
