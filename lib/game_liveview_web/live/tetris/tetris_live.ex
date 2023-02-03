defmodule GameLiveviewWeb.Tetris.TetrisLive do
  use Phoenix.LiveView
  use Phoenix.HTML

  @debug true
  @box_width 20
  @box_height 20

  def mount(_params, _session, socket) do
    :timer.send_interval 250, self(), :tick

    { :ok, start_game(socket) }
  end

  def render(%{state: :playing} = assigns) do
    ~L"""
      <h1><%= @score %></h1>
      <div phx-window-keydown="move_block">
        <%= raw svg_head() %>
        <%= raw boxes(@tetromino) %>
        <%= raw boxes(Map.values(@bottom)) %>
        <%= raw svg_foot() %>
      </div>
      <%= debug(assigns) %>
    """
  end

  def render(%{state: :starting} = assigns) do
    ~L"""
      <h1>Play Tetris!</h1>
      <button phx-click="start">Start</button>
    """
  end

  def render(%{state: :game_over} = assigns) do
    ~L"""
      <h1>Game Over</h1>
      <h2>Your score: <%= @score %></h2>
      <button phx-click="start">Play Again</button>
      <%= debug(assigns) %>
    """
  end

  defp new_game(socket) do
    assign(socket,
      state: :playing,
      score: 0,
      bottom: %{},
      game_over: false
    )
    |> new_block()
  end

  defp start_game(socket) do
    assign(socket,
    state: :starting
  )
  |> new_block()
  end

  def new_block(socket) do
    brick = Tetris.Brick.new_random_brick()
    |> Map.put(:location, {3, -3})


    assign(socket, [
        brick: brick
      ]
    )
    |> show()
  end

  def show(socket) do
    brick = socket.assigns.brick

    points = brick
    |> Tetris.Brick.prepare()
    |> Tetris.Points.move_to_location(brick.location)
    |> Tetris.Points.with_color(color(brick))

    assign(socket, [
      tetromino: points
    ])
  end

  def svg_head() do
    """
    <svg
    version="1.0"
    style="background-color: #F8F8F8"
    id="Layer_1"
    xmlns="http://www.w3.org/2000/svg"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    width="200" height="400"
    viewBox="0 0 200 400"
    xml:space="preserve">
    """
  end

  def svg_foot(), do: "</svg>"

  def boxes(points_with_colors) do
    points_with_colors
    |> Enum.map(fn {x, y, color} ->
        box({x, y}, color)
      end)
    |> Enum.join("\n")
  end

  def box(point, color) do
    """
    #{square(point, shades(color).light)}
    #{triangle(point, shades(color).dark)}
    """
  end

  def square(point, shade) do
    {x, y} = to_pixels(point)
    """
    <rect
    x="#{x + 1}" y="#{y + 1}"
    style="fill:##{shade};"
    width="#{@box_width - 2}" height="#{@box_height - 1}" />
    """
  end

  def triangle(point, shade) do
    {x, y} = to_pixels(point)
    {width, height} = {@box_width, @box_height}
    """
    <polyline
        style="fill:##{shade}"
        points="#{x + 1}, #{y + 1} #{x + width},#{y + 1} #{x + width},#{y + height}" />
    """
  end

  defp to_pixels({x, y}), do: {(x - 1) * @box_width, (y - 1) * @box_height}

  defp shades(:red), do: %{ light: "DB7160", dark: "AB574B"}
  defp shades(:blue), do: %{ light: "83C1C8", dark: "66969C"}
  defp shades(:green), do: %{ light: "8BBF57", dark: "769359"}
  defp shades(:orange), do: %{ light: "CB8E4E", dark: "AC7842"}
  defp shades(:grey), do: %{ light: "A1A09E", dark: "7F7F7E"}

  defp color(%{name: :t}), do: :red
  defp color(%{name: :i}), do: :blue
  defp color(%{name: :l}), do: :green
  defp color(%{name: :o}), do: :orange
  defp color(%{name: :z}), do: :grey

  def drop(:playing, socket) do
    old_brick = socket.assigns.brick
    color = color(old_brick)

    response = Tetris.drop(old_brick, socket.assigns.bottom, color)

    game_over = response.bottom
    |> Map.keys()
    |> Enum.map(&elem(&1, 1))
    |> Enum.any?(fn x -> x < 0 end)

    state = if game_over, do: :game_over, else: :playing

    socket
    |> assign(
        brick: response.brick,
        bottom: response.bottom,
        score: socket.assigns.score + response.score,
        state: state)
    |> show()
  end

  def drop(_not_playing, socket), do: socket

  def move(direction, socket) do
    socket
    |> do_move(direction)
    |> show()
  end

  def do_move(socket, :left) do
    assign(socket,
      brick: socket.assigns.brick |> Tetris.try_left(socket.assigns.bottom)
    )
  end

  def do_move(socket, :right) do
    assign(socket,
      brick: socket.assigns.brick |> Tetris.try_right(socket.assigns.bottom)
    )
  end

  def do_move(socket, :rotate) do
    assign(socket,
      brick: socket.assigns.brick |> Tetris.try_spin_90(socket.assigns.bottom)
    )
  end

  # def do_move(socket, :rotate) do
  #   assign(socket,
  #     brick: socket.assigns.brick |> Tetris.drop(socket.assigns.brick. socket.assigns.bottom, socket.assigns.brick.color)
  #   )
  # end

  def do_move(socket, _) do
    assign(socket,
      brick: socket.assigns.brick |> Tetris.Brick.right()
    )
  end


  def handle_event("move_block", %{"key" => "ArrowLeft"}, socket) do
    {:noreply, move(:left, socket)}
  end

  def handle_event("move_block", %{"key" => "ArrowRight"}, socket) do
    {:noreply, move(:right, socket)}
  end

  def handle_event("move_block", %{"key" => "ArrowDown"}, socket) do
    {:noreply, drop(socket.assigns.state, socket)}
  end

  def handle_event("move_block", %{"key" => "ArrowUp"}, socket) do
    {:noreply, move(:rotate, socket)}
  end

  def handle_event("move_block", _, socket), do: {:noreply, socket}

  def handle_event("start", _, socket) do
    {:noreply, new_game(socket)}
  end

  def handle_info(:tick, socket) do
    {:noreply, drop(socket.assigns.state, socket)}
  end


  def debug(assigns), do: debug(assigns, @debug, Mix.env)
  def debug(assigns, true, :dev) do
    ~L"""
    <pre>
      <%= raw @tetromino |> inspect %>
      <%= raw @bottom |> inspect %>
      <%= raw @state |> inspect %>
    </pre>
    """
  end
  def debug(_ , _, _), do: ""
end
