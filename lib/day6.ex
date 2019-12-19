defmodule Day6 do
  def part1 do
    orbits = parse_orbits(data())

    orbits
    |> Map.keys()
    |> Enum.reduce(0, fn planet, count -> steps_to_center(orbits, planet) + count end)
  end

  def part2 do
    orbits = parse_orbits(data())

    you = orbits["YOU"]
    santa = orbits["SAN"]

    fewest_orbital_transfers_between_planets(orbits, you, santa)
  end

  def data do
    Advent2019.input_blob(__MODULE__)
  end

  def test_data do
    """
    COM)B
    B)C
    C)D
    D)E
    E)F
    B)G
    G)H
    D)I
    E)J
    J)K
    K)L
    """
  end

  defmacro rl do
    quote do
      import Day6
    end
  end

  def parse_orbits(input) do
    rx = ~r/(\w+)\)(\w+)/

    Regex.scan(rx, input, capture: :all_but_first)
    |> Enum.into(%{}, fn [orbitted, orbitter] -> {orbitter, orbitted} end)
  end

  def steps_to_center(orbits, planet), do: steps_to_center(orbits, planet, 0)

  def steps_to_center(orbits, planet, count) do
    if planet == "COM" do
      count
    else
      steps_to_center(orbits, orbits[planet], count + 1)
    end
  end

  # Returns the path FROM the center to the planet specified.
  def path_from_center(orbits, planet), do: path_from_center(orbits, planet, [planet])

  def path_from_center(orbits, planet, path) do
    if planet == "COM" do
      List.flatten(path)
    else
      path_from_center(orbits, orbits[planet], [orbits[planet] | path])
    end
  end

  def fewest_orbital_transfers_between_planets(orbits, pA, pB) do
    pathA = path_from_center(orbits, pA) -- path_from_center(orbits, pB)
    pathB = path_from_center(orbits, pB) -- path_from_center(orbits, pA)
    Enum.count(pathA) + Enum.count(pathB)
  end
end
