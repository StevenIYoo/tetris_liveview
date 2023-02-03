defmodule BottomTest do
  use ExUnit.Case

  alias Tetris.Bottom

  test "various collisions" do
    bottom = %{{1, 1} => {1, 1, :blue}}

    assert Bottom.collides?(bottom, {1, 1}) == true
    assert Bottom.collides?(bottom, {1, 2}) == false
    assert Bottom.collides?(bottom, {1, 1, :blue}) == true
    assert Bottom.collides?(bottom, {1, 1, :red}) == true
    refute Bottom.collides?(bottom, {1, 2, :red})
    assert Bottom.collides?(bottom, [{1, 2, :red}, {1, 1, :red}])
    refute Bottom.collides?(bottom, [{1, 2, :red}, {1, 3, :red}])
  end

  test "various merges" do
    bottom = %{{1, 1} => {1, 1, :blue}}

    actual = Bottom.merge(bottom, [{1, 2, :red}, {1, 3, :red}])

    expected = %{
      {1, 1} => {1, 1, :blue},
      {1, 2} => {1, 2, :red},
      {1, 3} => {1, 3, :red}
    }

    assert actual == expected
  end

  test "compute complete ys" do
    bottom = new_bottom(20, [{{19, 19}, {19, 19, :red}}])

    assert Bottom.complete_ys(bottom) == [20]
  end

  test "collapse single row" do
    bottom = new_bottom(20, [{{19, 19}, {19, 19, :red}}])

    actual = Map.keys(Bottom.collapse_row(bottom, 20))

    refute {19, 19} in actual
    assert {19, 20} in actual
    assert Enum.count(actual) == 1
  end

  test "full collapse with single row" do
    bottom = new_bottom(20, [{{19, 19}, {19, 19, :red}}])

    {actual_count, actual_bottom} = Bottom.full_collapse(bottom)

    assert actual_count == 1
    assert {19, 20} in Map.keys(actual_bottom)
  end

  def new_bottom(complete_row, extras) do
    (extras ++
    (1..10
    |> Enum.map(fn x ->
        {{x, complete_row}, {x, complete_row, :red}}
      end)))
    |> Map.new()
  end
end
