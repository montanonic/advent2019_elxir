defmodule Day2 do
  def run do
    IO.inspect(part1(), label: "Part 1")
    IO.inspect(part2(), label: "Part 2")
  end

  def part1 do
    run_program(12, 2)
    |> hd()
  end

  def part2 do
    range = 0..99

    Stream.flat_map(range, fn noun ->
      Stream.map(range, fn verb ->
        output =
          run_program(noun, verb)
          |> hd()

        if output == 19_690_720 do
          {noun, verb}
        end
      end)
      |> Enum.filter(& &1)
    end)
    |> Enum.at(0)
    |> (fn {noun, verb} -> 100 * noun + verb end).()
  end

  def run_program(noun, verb) do
    Day2.Implementation.get_program()
    |> Day2.Implementation.set_noun_and_verb(noun, verb)
    |> Day2.Implementation.run_program()
  end

  defmodule Implementation do
    def set_noun_and_verb(program, noun, verb) do
      program
      |> List.replace_at(1, noun)
      |> List.replace_at(2, verb)
    end

    def get_program do
      Advent2019.input_lines(2)
      |> Enum.at(0)
      |> parse_program()
    end

    def parse_program(string) do
      string
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)
    end

    def run_program(program), do: run_program(program, {program, 1})

    def run_program([99 | _], {acc, _}), do: acc

    def run_program([opcode, x, y, index | _], {acc, count}) do
      op =
        case opcode do
          1 -> &+/2
          2 -> &*/2
        end

      updated_program = List.replace_at(acc, index, op.(Enum.at(acc, x), Enum.at(acc, y)))
      run_program(Enum.drop(updated_program, 4 * count), {updated_program, count + 1})
    end
  end
end
