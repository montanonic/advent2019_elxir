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

  def run_program(module) do
    Day2.Implementation.get_program(module)
    |> Day2.Implementation.run_program()
  end

  def run_program(noun, verb, module \\ __MODULE__) do
    Day2.Implementation.get_program(module)
    |> Day2.Implementation.set_noun_and_verb(noun, verb)
    |> Day2.Implementation.run_program()
  end

  defmodule Implementation do
    def set_noun_and_verb(program, noun, verb) do
      program
      |> Map.put(1, noun)
      |> Map.put(2, verb)
    end

    def get_program(module \\ __MODULE__) do
      Advent2019.input_lines(module)
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

    def run_program(program) do
      # Store diagnostic info from op_4
      Agent.start_link(fn -> [] end, name: :diagnostics)

      max_index = Map.keys(program) |> Enum.max()

      run_program(program, 0, max_index)
    end

    def run_program(program, pointer, max_index) do
      operation = Map.get(program, pointer) |> parse_operation()
      # Advance the pointer to the next instruction now that we've parsed the operation.
      pointer = pointer + 1

      case run_operation(program, pointer, operation, max_index) do
        {program, _, :halt} -> program
        {program, pointer, _} -> run_program(program, pointer + 1, max_index)
      end
    end

    def get_diagnostics(), do: Agent.get(:diagnostics, &Enum.reverse/1)

    # Runs the operation on the program, returning the new program along with
    # where the pointer is at. The given pointer should be to the value after
    # the operation, not the operation itself (which you should already have as
    # you're providing it in the function call).
    defp run_operation(program, pointer, %{opcode: opcode, a: a, b: b, c: c}, max_index) do
      param_modes = [a, b, c]

      {fun, num_inputs} =
        case opcode do
          1 -> {&op_1/4, 3}
          2 -> {&op_2/4, 3}
          3 -> {&op_3/2, 1}
          4 -> {&op_4(&1, pointer, &2), 1}
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
        param_modes_and_pointers
        |> Enum.map(fn {mode, pointer} ->
          {mode, Map.get(program, pointer)}
        end)
        |> Enum.map(&validate_param(&1, max_index))

      res = {apply(fun, [program | param_modes_and_values]), pointer, opcode == 99 && :halt}
      res
    end

    # Ensure that param lookups fall within the range of the program.
    defp validate_param({:position, value} = param, max_index) when value in 0..max_index,
      do: param

    defp validate_param({:immediate, _} = param, _), do: param

    def parse_operation(operation_num) do
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

    defp op_1(program, a, b, {:position, pointer}),
      do: Map.put(program, pointer, get_param(program, a) + get_param(program, b))

    defp op_2(program, a, b, {:position, pointer}),
      do: Map.put(program, pointer, get_param(program, a) * get_param(program, b))

    defp op_3(program, {:position, pointer}), do: Map.put(program, pointer, 1)

    defp op_4(program, position, {:position, pointer}) do
      output = {position, Map.get(program, pointer)}

      Agent.update(:diagnostics, fn list -> [output | list] end)

      program
    end

    def op_99(program), do: program
  end
end
