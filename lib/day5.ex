defmodule Day5 do
  def run do
    IO.inspect(part1(), label: "Part 1")
    IO.inspect(part2(), label: "Part 2")
  end

  def part1 do
    Day5.Impl.get_program([1])
    |> Day5.Impl.run_program()
  end

  def part2 do
    Day5.Impl.get_program([5])
    |> Day5.Impl.run_program()
  end

  defmodule Impl do
    def get_program(input_buffer) do
      memory =
        Advent2019.input_file(Day5)
        |> File.read!()
        |> String.trim()
        |> String.split(",")
        |> Stream.with_index()
        |> Stream.map(fn {v, i} -> {i, String.to_integer(v)} end)
        |> Map.new()

      %{
        memory: memory,
        pointer: 0,
        input_buffer: input_buffer,
        output: [],
        halt: false,
        jumped: false
      }
    end

    def run_program(%{halt: true} = program), do: output(program)

    def run_program(program) do
      run_program(step_program(program))
    end

    # Executes the current program instruction, returning the next program state.
    defp step_program(%{memory: memory, pointer: pointer} = program) do
      instruction = interpret_instruction(memory[pointer])

      parameters = get_parameters_for_instruction(program, instruction)

      program = apply(instruction.function, [program | parameters])

      %{
        program
        | jumped: false,
          # Skip incrementing the pointer if the program jumped.
          pointer:
            if program.jumped do
              program.pointer
            else
              program.pointer + Enum.count(parameters) + 1
            end
      }
    end

    defp get_parameters_for_instruction(%{pointer: pointer} = program, %{
           arity: arity,
           p1_mode: p1_mode,
           p2_mode: p2_mode,
           p3_mode: p3_mode
         }) do
      [pointer + 1, pointer + 2, pointer + 3]
      |> Enum.take(max(arity - 1, 0))
      |> Enum.map(&read(program, &1))
      |> Enum.zip([p1_mode, p2_mode, p3_mode])
    end

    defp interpret_instruction(instruction) do
      digits = Integer.digits(instruction)
      padding = Stream.repeatedly(fn -> 0 end) |> Enum.take(abs(5 - Enum.count(digits)))
      [a, b, c, d, e] = padding ++ digits

      opcode = d * 10 + e
      {function, arity} = lookup_instruction(opcode)

      %{
        opcode: opcode,
        function: function,
        arity: arity,
        p1_mode: parameter_mode(c),
        p2_mode: parameter_mode(b),
        p3_mode: parameter_mode(a)
      }
    end

    defp parameter_mode(0), do: :position
    defp parameter_mode(1), do: :immediate

    # Returns a tuple with the callable function for the given instruction
    # corresponding to the given opcode, along with a the arity of that
    # function.
    defp lookup_instruction(opcode) do
      fun = instruction_table()[opcode]
      {:arity, arity} = Function.info(fun, :arity)
      {fun, arity}
    end

    defp instruction_table do
      %{
        1 => calc(&+/2),
        2 => calc(&*/2),
        3 => &input/2,
        4 => &output/2,
        5 => jump_if(true),
        6 => jump_if(false),
        7 => compare(&</2),
        8 => compare(&==/2),
        99 => &halt/1
      }
    end

    # Read a parameter out from program memory.
    defp read(program, {param, :position}), do: Map.fetch!(program.memory, param)
    defp read(_program, {param, :immediate}), do: param
    # Modeless read (for getting parameters from a pointer).
    defp read(program, param) when not is_tuple(param), do: Map.fetch!(program.memory, param)

    defp write(program, index, value), do: put_in(program.memory[index], value)

    defp calc(bin_op) do
      fn program, x, y, {index, :position} ->
        sum = bin_op.(read(program, x), read(program, y))
        write(program, index, sum)
      end
    end

    defp input(program, {index, :position}) do
      {[value], rest} = Enum.split(program.input_buffer, 1)

      write(program, index, value)
      |> Map.put(:input_buffer, rest)
    end

    defp output(program), do: List.flatten(program.output)
    defp output(program, x), do: update_in(program.output, &[&1, read(program, x)])

    defp jump_if(condition) do
      fn program, a, b ->
        if read(program, a) != 0 == condition do
          put_in(program.pointer, read(program, b))
          |> Map.put(:jumped, true)
        else
          program
        end
      end
    end

    defp compare(predicate) do
      fn program, a, b, {index, :position} ->
        value = if predicate.(read(program, a), read(program, b)), do: 1, else: 0
        put_in(program.memory[index], value)
      end
    end

    def halt(program), do: %{program | halt: true}
  end
end
