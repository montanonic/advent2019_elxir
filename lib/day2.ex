defmodule Day2 do
  def run do
    IO.inspect(part1())
  end

  def part1 do
    Day2.Implementation.get_program()
    |> List.replace_at(1, 12)
    |> List.replace_at(2, 2)
    |> Day2.Implementation.run_program()
    |> hd()
  end

  defmodule Implementation do
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
