defmodule Tetris.Brick do
  alias Tetris.Points

  @x_center 40
  @shapes ~w(i l z o t)a
  @rotations [0, 90, 180, 270]
  @reflections [true, false]

  defstruct [
    name: :i,
    location: {40, 0},
    rotation: 0,
    reflection: false
  ]

  @spec new_brick(any) :: %Tetris.Brick{
          location: {40, 0},
          name: :i,
          reflection: false,
          rotation: 0
        }
  def new_brick(attributes \\ []), do: __struct__(attributes)

  @spec new_random_brick :: %Tetris.Brick{}
  def new_random_brick() do
    new_brick()
    |> change_name(random_name())
    |> change_location(3, -3)
    |> change_rotation(random_rotation())
    |> change_reflection(random_reflection())
  end
  def change_name(brick, name), do: Map.put(brick, :name, name)

  def change_rotation(brick, rotation), do: Map.put(brick, :rotation, rotation)

  def change_reflection(brick, reflection), do: Map.put(brick, :reflection, reflection)

  def change_location(brick, x, y), do: Map.put(brick, :location, {x, y})

  def random_name(), do: @shapes |> random()

  def random_rotation(), do: @rotations |> random()

  def random_reflection(), do: @reflections |> random()

  def random(list), do: list |> Enum.random()

  def left(brick), do: brick |> Map.put(:location, move_left(brick.location))

  def right(brick), do: brick |> Map.put(:location, move_right(brick.location))

  def down(brick), do: brick |> Map.put(:location, move_down(brick.location))

  def spin_90(brick), do: brick |> Map.put(:rotation, rotate(brick.rotation))

  def shape(%{name: :l}) do
    [
      {2, 1},
      {2, 2},
      {2, 3}, {3, 3},
    ]
  end

  def shape(%{name: :i}) do
    [
      {2, 1},
      {2, 2},
      {2, 3},
      {2, 4},
    ]
  end

  def shape(%{name: :o}) do
    [
      {2, 1}, {2, 2},
      {3, 1}, {3, 2},
    ]
  end

  def shape(%{name: :z}) do
    [
      {2, 2},
      {2, 3}, {3, 3},
              {3, 4},
    ]
  end

  def shape(%{name: :t}) do
    [
      {2, 1},
      {2, 2}, {3, 2},
      {2, 3},
    ]
  end

  def prepare(brick) do
    brick
    |> shape()
    |> Points.rotate(brick.rotation)
    |> Points.mirror(brick.reflection)
  end

  def to_string(brick) do
    brick = prepare(brick)
    |> Points.to_string()

    brick
  end

  def print(brick) do
    brick
    |> prepare()
    |> Points.print()

    brick
  end

  def color(%{name: :i}), do: :blue
  def color(%{name: :l}), do: :green
  def color(%{name: :z}), do: :orange
  def color(%{name: :o}), do: :red
  def color(%{name: :t}), do: :yellow

  def x_center(), do: @x_center

  def render(brick) do
    brick
    |> prepare()
    |> Points.move_to_location(brick.location)
    |> Points.with_color(color(brick))
  end

  defimpl Inspect, for: Tetris.Brick do
    import Inspect.Algebra
    def inspect(brick, _opts) do
      concat([Tetris.Brick.to_string(brick),
      "\n", inspect(brick.location),
      "\n", inspect(brick.reflection),
      "\n", inspect(brick.rotation)
      ])
    end
  end

  defp move_left({x, y}), do: {x - 1, y}

  defp move_right({x, y}), do: {x + 1, y}

  defp move_down({x, y}), do: {x, y + 1}

  defp rotate(degrees) when degrees >= 270, do: 0
  defp rotate(degrees), do: degrees + 90

  def get_available_shapes(), do: @shapes
  def get_available_rotations(), do: @rotations
  def get_available_reflections(), do: @reflections
end
