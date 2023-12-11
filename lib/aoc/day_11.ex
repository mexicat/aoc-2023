defmodule AoC.Day11 do
  def part1(input) do
    input
    |> parse_input()
    |> expand()
    |> find_paths()
  end

  def part2(input) do
    input
    |> parse_input()
    |> expand(1_000_000 - 1)
    |> find_paths()
  end

  def find_paths(universe) do
    universe
    |> Enum.map(fn a -> Enum.map(universe, fn b -> distance(a, b) end) |> Enum.sum() end)
    |> Enum.sum()
    |> div(2)
  end

  def expand(universe, n \\ 1) do
    max_x = universe |> Enum.map(fn {x, _} -> x end) |> Enum.max()
    max_y = universe |> Enum.map(fn {_, y} -> y end) |> Enum.max()

    xs =
      for x <- 0..max_x,
          not Enum.any?(universe, fn {x2, _} -> x == x2 end),
          do: x,
          into: MapSet.new()

    ys =
      for y <- 0..max_y,
          not Enum.any?(universe, fn {_, y2} -> y == y2 end),
          do: y,
          into: MapSet.new()

    universe
    |> Enum.map(fn {x, y} ->
      x1 = x + Enum.count(xs, fn x2 -> x2 < x end) * n
      y1 = y + Enum.count(ys, fn y2 -> y2 < y end) * n
      {x1, y1}
    end)
    |> MapSet.new()
  end

  def distance({x1, y1}, {x2, y2}), do: abs(x1 - x2) + abs(y1 - y2)

  def parse_input(input) do
    input
    |> String.codepoints()
    |> Enum.reduce({MapSet.new(), 0, 0}, fn c, {acc, x, y} ->
      case c do
        "#" -> {MapSet.put(acc, {x, y}), x + 1, y}
        "." -> {acc, x + 1, y}
        "\n" -> {acc, 0, y + 1}
      end
    end)
    |> elem(0)
  end
end
