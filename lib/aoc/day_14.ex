defmodule AoC.Day14 do
  def part1(input) do
    grid = input |> parse_input()
    max_x = grid |> Enum.map(fn {{x, _y}, _} -> x end) |> Enum.max()
    max_y = grid |> Enum.map(fn {{_x, y}, _} -> y end) |> Enum.max()
    grid = tilt(grid, :up, max_x, max_y)
    count(grid)
  end

  def part2(input) do
    cycles = 1_000_000_000 * 4
    grid = input |> parse_input()

    max_x = grid |> Enum.map(fn {{x, _y}, _} -> x end) |> Enum.max()
    max_y = grid |> Enum.map(fn {{_x, y}, _} -> y end) |> Enum.max()

    [:up, :left, :down, :right]
    |> Stream.cycle()
    |> Enum.reduce_while({1, grid, %{}}, fn
      _, {^cycles, acc, _} ->
        {:halt, count(acc)}

      dir, {n, acc, found} ->
        grid = tilt(acc, dir, max_x, max_y)

        if Map.has_key?(found, grid) do
          iter = n - Map.get(found, grid)
          n = up_to(cycles, n, iter)
          {:cont, {n, grid, %{}}}
        else
          {:cont, {n + 1, grid, Map.put(found, grid, n)}}
        end
    end)
  end

  def up_to(max, curr, iter) do
    case curr + iter do
      x when x > max -> curr
      x -> up_to(max, x, iter)
    end
  end

  def tilt(grid, dir, max_x, max_y) do
    %{"#" => clean, "O" => grid} = Enum.group_by(grid, fn {_, v} -> v end)
    grid = Enum.sort(grid, dirs(dir)[:sort])

    Enum.reduce(grid, Map.new(clean), fn {point, "O"}, acc ->
      Map.put(acc, find_free_spot(acc, point, dirs(dir)[:next], max_x, max_y), "O")
    end)
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

  def count(grid) do
    max_y = grid |> Enum.map(fn {{_, y}, _} -> y end) |> Enum.max()

    Enum.reduce(grid, 0, fn
      {{_x, y}, "O"}, acc -> -y + max_y + 1 + acc
      _, acc -> acc
    end)
  end

  def find_free_spot(grid, {x, y}, dir = {x1, y1}, max_x, max_y) do
    next = {x + x1, y + y1}
    check = Map.get(grid, next)

    cond do
      check in ["O", "#"] ->
        {x, y}

      (y == 0 and dir == dirs(:up)[:next]) or (y == max_y and dir == dirs(:down)[:next]) or
        (x == 0 and dir == dirs(:left)[:next]) or (x == max_x and dir == dirs(:right)[:next]) ->
        {x, y}

      true ->
        find_free_spot(grid, next, {x1, y1}, max_x, max_y)
    end
  end

  def dirs(:up), do: %{next: {0, -1}, sort: fn {{_x1, y1}, _}, {{_x2, y2}, _} -> y1 < y2 end}
  def dirs(:down), do: %{next: {0, 1}, sort: fn {{_x1, y1}, _}, {{_x2, y2}, _} -> y1 > y2 end}
  def dirs(:left), do: %{next: {-1, 0}, sort: fn {{x1, _y1}, _}, {{x2, _y2}, _} -> x1 < x2 end}
  def dirs(:right), do: %{next: {1, 0}, sort: fn {{x1, _y1}, _}, {{x2, _y2}, _} -> x1 > x2 end}

  def parse_input(input) do
    input
    |> String.codepoints()
    |> Enum.reduce({%{}, 0, 0}, fn c, {acc, x, y} ->
      case c do
        "." -> {acc, x + 1, y}
        "\n" -> {acc, 0, y + 1}
        a -> {Map.put(acc, {x, y}, a), x + 1, y}
      end
    end)
    |> elem(0)
  end
end
