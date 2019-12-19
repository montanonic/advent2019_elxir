defmodule Day6 do
  def part1 do
    orbits = parse_orbits(data())

    orbits
    |> Map.keys()
    |> Enum.reduce(0, fn planet, count -> steps_to_center(orbits, planet) + count end)
  end

  def part2 do
    orbits = parse_orbits(data())

    you_orbit = orbits["YOU"]
    santa_orbit = orbits["SAN"]

    fewest_orbital_transfers_between_planets(orbits, you_orbit, santa_orbit)
  end

  def data, do: Advent2019.input_blob(__MODULE__)

  def parse_orbits(input) do
    rx = ~r/(\w+)\)(\w+)/

    Regex.scan(rx, input, capture: :all_but_first)
    |> Enum.into(%{}, fn [orbitted, orbitter] -> {orbitter, orbitted} end)
  end

  def steps_to_center(orbits, planet, count \\ 0) do
    if planet == "COM" do
      count
    else
      steps_to_center(orbits, orbits[planet], count + 1)
    end
  end

  # Returns the path FROM the center to the planet specified.
  @spec path_from_center(any, any, [any]) :: [any]
  def path_from_center(orbits, planet, path \\ []) do
    if planet == "COM" do
      path
    else
      path_from_center(orbits, orbits[planet], [planet | path])
    end
  end

  def fewest_orbital_transfers_between_planets(orbits, pA, pB) do
    pathA = path_from_center(orbits, pA) -- path_from_center(orbits, pB)
    pathB = path_from_center(orbits, pB) -- path_from_center(orbits, pA)
    Enum.count(pathA) + Enum.count(pathB)
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
end
