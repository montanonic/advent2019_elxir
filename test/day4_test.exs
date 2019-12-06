defmodule Day4Test do
  use ExUnit.Case
  doctest Day4

  test "111111 meets these criteria (double 11, never decreases)" do
    assert Day4.valid_password?(111_111, exclude_range: true)
  end

  test "223450 does not meet these criteria (decreasing pair of digits 50)" do
    refute Day4.valid_password?(223_450, exclude_range: true)
  end

  test "123789 does not meet these criteria (no double)" do
    refute Day4.valid_password?(123_789, exclude_range: true)
  end

  test "112233 meets these criteria because the digits never decrease and all repeated digits are exactly two digits long" do
    assert Day4.valid_password?(112_233, exclude_range: true, part2: true)
  end

  test "123444 no longer meets the criteria (the repeated 44 is part of a larger group of 444)" do
    refute Day4.valid_password?(123_444, exclude_range: true, part2: true)
  end

  test "111122 meets the criteria (even though 1 is repeated more than twice, it still contains a double 22)" do
    assert Day4.valid_password?(111_122, exclude_range: true, part2: true)
  end
end
