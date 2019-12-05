defmodule Day2Test do
  use ExUnit.Case
  doctest Day2

  _program = """
  1,9,10,3,
  2,3,11,0,
  99,
  30,40,50
  """

  def run_program(program) do
    Day2.Implementation.run_program(program)
  end

  test "1 op" do
    assert run_program([1, 0, 0, 0, 99]) == [2, 0, 0, 0, 99]
  end

  test "2 op" do
    assert run_program([2, 3, 0, 3, 99]) == [2, 3, 0, 6, 99]
  end

  test "99 halts" do
    assert run_program([2, 4, 4, 5, 99, 0]) == [2, 4, 4, 5, 99, 9801]
  end

  test "replacing an opcode works; the new value is the new opcode" do
    assert run_program([1, 1, 1, 4, 99, 5, 6, 0, 99]) == [30, 1, 1, 4, 2, 5, 6, 0, 99]
  end
end
