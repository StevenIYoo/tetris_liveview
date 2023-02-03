defmodule BrickTest do
  use ExUnit.Case

  alias Tetris.Brick
  alias Tetris.Points

  test "creates a new brick" do
    assert Brick.new_brick().name == :i
  end

  test "creates a new random brick" do
    actual = Brick.new_random_brick()

    assert actual.name in Brick.get_available_shapes()
    assert actual.rotation in Brick.get_available_rotations()
    assert actual.reflection in Brick.get_available_reflections()
  end

  test "should manipulate brick" do
    actual = Brick.new_brick()
    |> Brick.left()
    |> Brick.right()
    |> Brick.right()
    |> Brick.down()
    |> Brick.spin_90()
    |> Brick.spin_90()

    assert actual.location == {41, 1}
    assert actual.rotation == 180
  end

  test "should return points for shape i" do
    points = Brick.new_brick(name: :i)
    |> Brick.shape()

    assert {2, 2} in points
  end

  # test "should translate a list of points" do
  #   points = Brick.new_brick()
  #   |> Brick.shape()

  #   points
  #   |> Points.transpose({1, 1})
  #   |> Points.transpose({0, 1})

  #   assert points == [
  #     {3, 3}, {3, 4}, {3, 5}, {3, 6}
  #   ]
  # end

  test "should flip rotate flip and mirror" do
    [{1, 1}]
    |> Points.mirror()
    |> assert_point({4, 1})
    |> Points.flip()
    |> assert_point({4, 4})
    |> Points.rotate(90)
    |> assert_point({1, 4})
    |> Points.rotate(90)
    |> assert_point({1, 1})
  end

  test "should convert brick to string" do
    actual = Brick.new_brick()
      |> Brick.to_string()

    expected = "⬜⬛⬜⬜\n⬜⬛⬜⬜\n⬜⬛⬜⬜\n⬜⬛⬜⬜"

    assert actual == expected
  end

  test "should inspect bricks" do
    actual = Brick.new_brick()
      |> inspect()

    expected =
      """
      ⬜⬛⬜⬜
      ⬜⬛⬜⬜
      ⬜⬛⬜⬜
      ⬜⬛⬜⬜
      {#{Brick.x_center()}, 0}
      false
      0
      """
      |> String.trim_trailing("\n")

    assert actual == expected
  end

  def assert_point([actual], expected) do
    assert actual == expected
    [actual]
  end

  def new_brick_from_attributes(attributes \\ []) do
    Brick.new_brick(attributes)
  end
end
