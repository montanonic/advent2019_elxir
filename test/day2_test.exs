defmodule Day2Test do
  use ExUnit.Case
  use PropCheck, default_opts: [{:numtests, 100}, {:max_shrinks, 1000}, :quiet]
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

  @thoughts """
  What are some properties of this system?

  The last operation must be 99.

  The input length and output length will be equal.


  """

  property "Invariant: output program is always the same length" do
    forall x <- non_empty(list(integer())) do
      try do
        length(x) == length(run_program(x))
      rescue
        _ -> true
      end
    end
  end

  property "Invariant: a successful program must contain a 99", numtests: 1000 do
    forall x <- non_empty(list(integer())) do
      try do
        99 in run_program(x)
      rescue
        _ -> true
      end
    end
  end

  test "1 op; 3 inputs, the first two are the indexes for input values, the third is the index where you place the input sum" do
    assert run_program([1, 0, 0, 0, 99]) == [2, 0, 0, 0, 99]
    assert run_program([11001, -30, 100, 3, 99]) == [11001, -30, 100, 70, 99]
  end

  test "2 op; 3 inputs, the first two are the indexes for input values, the third is the index where you place the input product" do
    assert run_program([2, 3, 0, 3, 99]) == [2, 3, 0, 6, 99]
    assert run_program([1002, 0, -3, 3, 99]) == [1002, 0, -3, -3006, 99]
  end

  test "3 op; 1 input, it should place a 1 at the position of its instruction" do
    assert run_program([3, 0, 99]) == [1, 0, 99]
    assert run_program([3, 0, 11001, 0, 0, 0, 99]) == [0, 0, 11001, 0, 0, 0, 99]
    assert run_program([3, 2, 99, 0, 3, 0, 99]) == [3, 2, 1, 0, 3, 0, 99]
  end

  test "4 op; 1 input, it should produce diagnostic information at the position of its instruction" do
    assert run_program([4, 2, 99]) == [4, 2, 99]
    assert Day2.Implementation.get_diagnostics() == [{1, 99}]
  end

  test "99 halts" do
    assert run_program([2, 4, 4, 5, 99, 0]) == [2, 4, 4, 5, 99, 9801]
  end

  # test "an operations parameter for write location should never be in immediate mode" do

  # end

  test "replacing an opcode works; the new value is the new opcode" do
    assert run_program([1, 1, 1, 4, 99, 5, 6, 0, 99]) == [30, 1, 1, 4, 2, 5, 6, 0, 99]
  end

  describe "Implementation" do
    test "parse_operation works" do
      assert Day2.Implementation.parse_operation(3) == %{
               opcode: 3,
               a: :position,
               b: :position,
               c: :position
             }

      assert Day2.Implementation.parse_operation(103) == %{
               opcode: 3,
               a: :position,
               b: :position,
               c: :immediate
             }

      assert Day2.Implementation.parse_operation(1103) == %{
               opcode: 3,
               a: :position,
               b: :immediate,
               c: :immediate
             }

      assert Day2.Implementation.parse_operation(13) == %{
               opcode: 13,
               a: :position,
               b: :position,
               c: :position
             },
             "Works with 2 digit opcodes even if they aren't supported, like 13 is not supported"
    end
  end
end
