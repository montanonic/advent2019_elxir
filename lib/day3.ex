defmodule Day3 do
  def run do
    IO.inspect(part1())
  end

  defp part1 do
    [wire1, wire2] =
      Advent2019.input_lines(3) |> Stream.map(&String.split(&1, ",")) |> Enum.to_list()

    wire1_segments = get_segments(wire1)

    wire2
    |> get_segments
    |> find_overlapping_segments(wire1_segments)
    |> Stream.flat_map(fn {segmentA, segmentB} -> find_point_of_intersection(segmentA, segmentB) end)
    |> Stream.map(fn {x, y} -> abs(x) + abs(y) end)
    |> Enum.min()
  end

  # This assumes that two segments are already identified as intersecting.
  defp find_point_of_intersection(
         [{xA1, yA1}, {xA2, yA2}] = _segmentA,
         [{xB1, yB1}, {xB2, yB2}] = _segmentB
       ) do
    xA_set = MapSet.new(xA1..xA2)
    xB_set = MapSet.new(xB1..xB2)
    yA_set = MapSet.new(yA1..yA2)
    yB_set = MapSet.new(yB1..yB2)

    Enum.zip(MapSet.intersection(xA_set, xB_set), MapSet.intersection(yA_set, yB_set))
  end

  defp find_overlapping_segments(wireA_segments, wireB_segments) do
    Stream.flat_map(wireA_segments, fn segment ->
      intersecting = Enum.filter(wireB_segments, &check_for_segment_intersection(segment, &1))

      if not Enum.empty?(intersecting) do
        Enum.map(intersecting, &{&1, segment})
      else
        []
      end
    end)
  end

  defp get_segments(wire) do
    wire
    |> Stream.map(&parse_direction/1)
    |> apply_directions()
    |> Stream.chunk_every(2, 1, :discard)
  end

  defp parse_direction(direction_str) do
    {orientation_str, distance_str} = String.split_at(direction_str, 1)
    distance = String.to_integer(distance_str)

    case orientation_str do
      "L" -> {-distance, 0}
      "R" -> {+distance, 0}
      "D" -> {0, -distance}
      "U" -> {0, +distance}
      unknown -> throw("unknown direction: #{unknown}")
    end
  end

  defp apply_directions(directions) do
    Stream.scan(directions, fn {x1, y1}, {x2, y2} ->
      {x1 + x2, y1 + y2}
    end)
  end

  # Two segments will have intersected if their x-coordinate and y-coordinate
  # ranges are not disjoint. That is, for both ranges, there is at least one
  # point of commonality.
  defp check_for_segment_intersection(
         [{xA1, yA1}, {xA2, yA2}] = _segmentA,
         [{xB1, yB1}, {xB2, yB2}] = _segmentB
       ) do
    not Range.disjoint?(xA1..xA2, xB1..xB2) && not Range.disjoint?(yA1..yA2, yB1..yB2)
  end
end
