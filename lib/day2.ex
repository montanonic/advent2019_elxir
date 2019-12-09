defmodule Day2 do
  def run do
    IO.inspect(part1(), label: "Part 1")
    IO.inspect(part2(), label: "Part 2")
  end

  def part1 do
    run_program(12, 2)
    |> Map.get(0)
  end

  def part2 do
    range = 0..99

    Stream.flat_map(range, fn noun ->
      Stream.map(range, fn verb ->
        output =
          run_program(noun, verb)
          |> Map.get(0)

        if output == 19_690_720 do
          {noun, verb}
        end
      end)
      |> Enum.filter(& &1)
    end)
    |> Enum.at(0)
    |> (fn {noun, verb} -> 100 * noun + verb end).()
  end

  def run_program(noun, verb, advent_day \\ 2) do
    Day2.Implementation.get_program(advent_day)
    |> Day2.Implementation.set_noun_and_verb(noun, verb)
    |> Day2.Implementation.run_program()
  end

  defmodule Implementation do
    def set_noun_and_verb(program, noun, verb) do
      program
      |> Map.put(1, noun)
      |> Map.put(2, verb)
    end

    def get_program(advent_day \\ 2) do
      Advent2019.input_lines(advent_day)
      |> Enum.at(0)
      |> parse_program()
    end

    defp parse_program(string) do
      string
      |> String.split(",")
      |> Stream.map(&String.to_integer/1)
      |> Stream.with_index()
      # Represents as a map
      |> Enum.into(%{}, fn {v, i} -> {i, v} end)
    end

    def run_program(program), do: run_program(program, 0)

    def run_program(program, pointer) do
      operation = Map.get(program, pointer) |> parse_operation()
      # Advance the pointer to the next instruction now that we've parsed the operation.
      pointer = pointer + 1

      case run_operation(program, pointer, operation) do
        {program, _, :halt} -> program
        {program, pointer, _} -> run_program(program, pointer + 1)
      end
    end

    # Runs the operation on the program, returning the new program along with
    # where the pointer is at. The given pointer should be to the value after
    # the operation, not the operation itself (which you should already have as
    # you're providing it in the function call).
    defp run_operation(program, pointer, %{opcode: opcode, a: a, b: b, c: c}) do
      param_modes = [a, b, c]

      {fun, num_inputs} =
        case opcode do
          1 -> {&op_1/4, 3}
          2 -> {&op_2/4, 3}
          3 -> {&op_3/2, 1}
          4 -> {&op_4/2, 1}
          99 -> {&op_99/1, 0}
        end

      param_modes_and_pointers =
        param_modes
        # Only use as many params as the operation takes as inputs.
        |> Enum.take(num_inputs)
        |> Enum.with_index(pointer)

      # Move the current pointer to the last instruction read.
      {_, pointer} = List.last(param_modes_and_pointers) || {nil, pointer}

      # Get the instruction values at the pointers.
      param_modes_and_values =
        Enum.map(param_modes_and_pointers, fn {mode, pointer} ->
          {mode, Map.get(program, pointer)}
        end)

      {apply(fun, [program | param_modes_and_values]), pointer, opcode == 99 && :halt}
    end

    defp parse_operation(operation_num) do
      [a, b, c, d, e] =
        operation_num
        |> Integer.to_string()
        |> String.pad_leading(5, "0")
        |> String.graphemes()
        |> Enum.map(&String.to_integer/1)

      [a, b, c] = Enum.map([a, b, c], &parse_mode/1)

      %{opcode: d * 10 + e, a: a, b: b, c: c}
    end

    defp parse_mode(0), do: :position
    defp parse_mode(1), do: :immediate

    defp get_param(program, {:position, param}), do: Map.get(program, param)
    defp get_param(_program, {:immediate, param}), do: param

    def op_1(program, a, b, {_, pointer}),
      do: Map.put(program, pointer, get_param(program, a) + get_param(program, b))

    def op_2(program, a, b, {_, pointer}),
      do: Map.put(program, pointer, get_param(program, a) * get_param(program, b))

    def op_3(program, {_, pointer}), do: Map.put(program, pointer, 1)

    def op_4(program, {_, pointer}) do
      IO.puts("Test log at #{pointer}: #{Map.get(program, pointer)}")
      program
    end

    def op_99(program), do: program
  end
end
