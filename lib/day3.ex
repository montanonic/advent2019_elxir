defmodule Day3 do
  def run do
    IO.inspect(part1())
    IO.inspect(part2())
  end

  defp part1 do
    all_points_of_intersection()
    |> Stream.map(fn %{x: x, y: y} -> abs(x) + abs(y) end)
    |> Enum.min()
  end

  defp part2 do
    all_points_of_intersection("R75,D30,R83,U83,L12,D49,R71,U7,L72
    U62,R66,U55,R34,D71,R55,D58,R83")
    |> Enum.at(0)
    |> Map.get(:steps)
  end

  defp all_points_of_intersection(manual \\ nil) do
    [wire1, wire2] = get_wires(manual)
    wire1_segments = get_segments(wire1, :A)

    wire2
    |> get_segments(:B)
    |> find_overlapping_segments(wire1_segments)
    |> Enum.map(&IO.inspect(&1, label: "thing"))
    |> Stream.map(fn {segmentA, segmentB} ->
      find_point_of_intersection(segmentA, segmentB)
    end)
  end

  defp get_wires(manual) do
    manual_lines = manual && manual |> String.split("\n") |> Enum.map(&String.trim/1)

    (manual_lines || Advent2019.input_lines(__MODULE__))
    |> Stream.map(&String.split(&1, ","))
    |> Enum.to_list()
  end

  # This assumes that two segments are already identified as intersecting.
  defp find_point_of_intersection(
         [%{x: xA1, y: yA1}, %{x: xA2, y: yA2, steps: stepsA}] = _segmentA,
         [%{x: xB1, y: yB1}, %{x: xB2, y: yB2, steps: stepsB}] = _segmentB
       ) do
    xA_set = MapSet.new(xA1..xA2)
    xB_set = MapSet.new(xB1..xB2)
    yA_set = MapSet.new(yA1..yA2)
    yB_set = MapSet.new(yB1..yB2)

    Enum.zip(MapSet.intersection(xA_set, xB_set), MapSet.intersection(yA_set, yB_set))
    |> Enum.at(0)
    |> (fn {x_intersect, y_intersect} ->
          %{x: x_intersect, y: y_intersect, steps: stepsA + stepsB}
        end).()
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

  defp get_segments(wire, wire_label) do
    wire
    |> Stream.map(&parse_direction(&1, wire_label))
    |> apply_directions()
    |> Stream.chunk_every(2, 1, :discard)
  end

  defp parse_direction(direction_str, wire_label) do
    {orientation_str, distance_str} = String.split_at(direction_str, 1)
    distance = String.to_integer(distance_str)

    case orientation_str do
      "L" -> {-distance, 0}
      "R" -> {+distance, 0}
      "D" -> {0, -distance}
      "U" -> {0, +distance}
      unknown -> throw("unknown direction: #{unknown}")
    end
    |> (fn {x, y} -> %{x: x, y: y, wire: wire_label} end).()
  end

  defp apply_directions(directions) do
    Stream.scan(directions, %{x: 0, y: 0, steps: 0}, fn %{x: x1, y: y1},
                                                        %{x: x2, y: y2, steps: steps} ->
      %{x: x1 + x2, y: y1 + y2, steps: steps + abs(x1) + abs(y1)}
    end)
  end

  # Two segments will have intersected if their x-coordinate and y-coordinate
  # ranges are not disjoint. That is, for both ranges, there is at least one
  # point of commonality.
  defp check_for_segment_intersection(
         [%{x: xA1, y: yA1}, %{x: xA2, y: yA2}] = _segmentA,
         [%{x: xB1, y: yB1}, %{x: xB2, y: yB2}] = _segmentB
       ) do
    not Range.disjoint?(xA1..xA2, xB1..xB2) && not Range.disjoint?(yA1..yA2, yB1..yB2)
  end
end
