defmodule Day4 do
  @puzzle_input "152085-670283"

  def run do
    IO.inspect(part1(), label: "Part 1")
    IO.inspect(part2(), label: "Part 2")
  end

  def part1 do
    for password <- range(), valid_password?(password) do
      password
    end
    |> Enum.count()
  end

  def part2 do
    for password <- range(), valid_password?(password, part2: true) do
      password
    end
    |> Enum.count()
  end

  def valid_password?(password, opts \\ []) do
    [
      (Keyword.get(opts, :exclude_range) && fn _ -> true end) || (&within_range/1),
      &is_six_digits/1,
      &digits_are_ascending/1,
      &has_adjacent_equal_digits(&1, part2: Keyword.get(opts, :part2))
    ]
    |> Enum.map(& &1.(password))
    |> Enum.all?()
  end

  defp range do
    [start, end_] =
      String.split(@puzzle_input, "-")
      |> Enum.map(&String.to_integer/1)

    start..end_
  end

  defp within_range(password), do: password in range()

  defp is_six_digits(password) do
    password |> Integer.digits() |> Enum.count() == 6
  end

  # At least a pair of 2
  defp has_adjacent_equal_digits(password, opts) do
    chunk_op =
      if Keyword.get(opts, :part2) do
        fn x ->
          x
          |> Stream.chunk_by(& &1)
          |> Stream.filter(&(Enum.count(&1) == 2))
        end
      else
        &Stream.chunk_every(&1, 2, 1, :discard)
      end

    password
    |> Integer.digits()
    |> chunk_op.()
    |> Enum.any?(fn [a, b] -> a == b end)
  end

  defp digits_are_ascending(password) do
    digits = Integer.digits(password)
    Enum.sort(digits) == digits
  end
end
