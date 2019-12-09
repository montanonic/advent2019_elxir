defmodule Day2Test do
  use ExUnit.Case
  doctest Day2

  def run_program(program) do
    program
    # Change into a map
    |> Stream.with_index()
    |> Enum.into(%{}, fn {v, i} -> {i, v} end)
    |> Day2.Implementation.run_program()
    #  Now back into a list
    |> Enum.sort_by(fn {k, _v} -> k end)
    |> Enum.map(fn {_k, v} -> v end)
  end

  test "opcodes parsing gets both the operation AND parameter modes" do
  end

  test "1 op; 3 inputs, the first two are the indexes for input values, the third is the index where you place the input sum" do
    assert run_program([1, 0, 0, 0, 99]) == [2, 0, 0, 0, 99]
  end

  test "2 op; 3 inputs, the first two are the indexes for input values, the third is the index where you place the input product" do
    assert run_program([2, 3, 0, 3, 99]) == [2, 3, 0, 6, 99]
  end

  test "99 halts" do
    assert run_program([2, 4, 4, 5, 99, 0]) == [2, 4, 4, 5, 99, 9801]
  end

  test "replacing an opcode works; the new value is the new opcode" do
    assert run_program([1, 1, 1, 4, 99, 5, 6, 0, 99]) == [30, 1, 1, 4, 2, 5, 6, 0, 99]
  end
end
