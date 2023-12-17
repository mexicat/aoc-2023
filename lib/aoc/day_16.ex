defmodule AoC.Day16 do
  @dirs %{
    up: {0, -1},
    down: {0, 1},
    left: {-1, 0},
    right: {1, 0}
  }

  @reflections %{
    {:right, "/"} => [:up],
    {:right, "\\"} => [:down],
    {:right, "|"} => [:up, :down],
    {:right, "-"} => [:right],
    {:left, "/"} => [:down],
    {:left, "\\"} => [:up],
    {:left, "|"} => [:up, :down],
    {:left, "-"} => [:left],
    {:up, "/"} => [:right],
    {:up, "\\"} => [:left],
    {:up, "|"} => [:up],
    {:up, "-"} => [:left, :right],
    {:down, "/"} => [:left],
    {:down, "\\"} => [:right],
    {:down, "|"} => [:down],
    {:down, "-"} => [:left, :right]
  }

  def part1(input) do
    grid = input |> parse_input()
    max_x = grid |> Enum.map(fn {{x, _}, _} -> x end) |> Enum.max()
    max_y = grid |> Enum.map(fn {{_, y}, _} -> y end) |> Enum.max()

    bounce(grid, max_x, max_y, {0, 0}, :right, MapSet.new())
    |> Enum.reduce(%{}, fn {_, {x, y}}, acc -> Map.put(acc, {x, y}, "#") end)
    |> visualize()
    |> map_size()
  end

  def part2(input) do
    grid = input |> parse_input()
    max_x = grid |> Enum.map(fn {{x, _}, _} -> x end) |> Enum.max()
    max_y = grid |> Enum.map(fn {{_, y}, _} -> y end) |> Enum.max()

    starts =
      for(x <- 0..max_x, do: {{x, 0}, :down}) ++
        for(x <- 0..max_x, do: {{x, max_y}, :up}) ++
        for(y <- 0..max_y, do: {{0, y}, :right}) ++
        for(y <- 0..max_y, do: {{max_x, y}, :left})

    starts
    |> Task.async_stream(
      fn {start, dir} ->
        bounce(grid, max_x, max_y, start, dir, MapSet.new())
      end,
      ordered: false,
      timeout: :infinity
    )
    |> Stream.map(fn {:ok, res} ->
      res
      |> Enum.reduce(MapSet.new(), fn {_, {x, y}}, acc -> MapSet.put(acc, {x, y}) end)
      |> MapSet.size()
    end)
    |> Enum.max()
  end

  def bounce(_, max_x, max_y, {x, y}, dir, visited) when x < 0 or x > max_x or y < 0 or y > max_y,
    do: visited

  def bounce(grid, max_x, max_y, {x, y}, dir, visited) do
    if MapSet.member?(visited, {dir, {x, y}}) do
      visited
    else
      do_bounce(grid, max_x, max_y, {x, y}, dir, visited)
    end
  end

  def do_bounce(grid, max_x, max_y, {x, y}, dir, visited) do
    check = Map.get(grid, {x, y}, nil)
    visited = MapSet.put(visited, {dir, {x, y}})

    case check do
      nil ->
        {dx, dy} = Map.get(@dirs, dir)
        next = {x + dx, y + dy}
        bounce(grid, max_x, max_y, next, dir, visited)

      _ ->
        Map.get(@reflections, {dir, check}, nil)
        |> Enum.reduce(visited, fn newdir, acc ->
          {dx, dy} = Map.get(@dirs, newdir)
          next = {x + dx, y + dy}
          MapSet.union(acc, bounce(grid, max_x, max_y, next, newdir, acc))
        end)
        |> MapSet.union(visited)
    end
  end

  def visualize(grid) do
    IO.puts("\n")
    max_x = grid |> Enum.map(fn {{x, _y}, _} -> x end) |> Enum.max()
    max_y = grid |> Enum.map(fn {{_x, y}, _} -> y end) |> Enum.max()
    min_x = grid |> Enum.map(fn {{x, _y}, _} -> x end) |> Enum.min()
    min_y = grid |> Enum.map(fn {{_x, y}, _} -> y end) |> Enum.min()

    for y <- min_y..max_y do
      for x <- min_x..max_x do
        Map.get(grid, {x, y}, ".")
      end
      |> Enum.join()
    end
    |> Enum.join("\n")
    |> IO.puts()

    grid
  end

  def parse_input(input) do
    input
    |> String.codepoints()
    |> Enum.reduce({0, 0, %{}}, fn char, {x, y, grid} ->
      case char do
        "." -> {x + 1, y, grid}
        "\n" -> {0, y + 1, grid}
        _ -> {x + 1, y, Map.put(grid, {x, y}, char)}
      end
    end)
    |> elem(2)
    |> visualize()
  end
end
