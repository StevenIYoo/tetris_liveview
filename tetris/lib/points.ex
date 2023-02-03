defmodule Tetris.Points do
  #Renders Points on Canvas
  def move_to_location(points, {x, y}) do
    Enum.map(points, fn {dx, dy} -> { dx + x, dy + y } end)
  end

  def with_color(points, color) do
    Enum.map(points, &add_color(&1, color))
  end

  defp add_color({x, y}, color), do: {x, y, color}
  defp add_color(point, _color), do: point

  def rotate(points, 0), do: points
  def rotate(points, degrees) do
    rotate(
      rotate_90(points),
      degrees - 90
    )
  end

  def transpose(points), do: points |> Enum.map(&transpose_point/1)
  def mirror(points), do: points |> Enum.map(&mirror_point/1)
  def mirror(points, false), do: points
  def mirror(points, true), do: mirror(points)
  def flip(points), do: points |> Enum.map(&flip_point/1)

  def to_string(points) do
    map = points
    |> Enum.map(&({&1, "⬛"}))
    |> Map.new()

    for y <- (1..4), x <- (1..4) do
      Map.get(map, {x, y}, "⬜")
    end
    |> Enum.chunk_every(4)
    |> Enum.map(&(Enum.join/1))
    |> Enum.join("\n")
  end

  def print(points) do
    IO.puts __MODULE__.to_string(points)
    points
  end

  defp rotate_90(points) do
    points
    |> transpose()
    |> mirror()
  end

  defp transpose_point({x, y}), do: {y, x}
  defp mirror_point({x, y}), do: {5 - x, y}
  defp flip_point({x, y}), do: {x, 5 - y}
end

"SuPRISE INbOUND"
|> String.replace(" ", "")
|> String.graphemes()
|> Enum.filter(&(&1 == String.downcase(&1)))
|> Enum.map(&(String.upcase/1))
|> Enum.join()
|> IO.puts()
