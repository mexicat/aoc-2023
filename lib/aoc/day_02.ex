defmodule AoC.Day02 do
  def part1(input) do
    input
    |> parse_input()
    |> Enum.with_index(1)
    |> Enum.filter(fn {line, _} -> plausible_cubes(line, 12, 13, 14) end)
    |> Enum.map(fn {_, i} -> i end)
    |> Enum.sum()
  end

  def part2(input) do
    input
    |> parse_input()
    |> Enum.map(&fewest_cubes_needed/1)
    |> Enum.sum()
  end

  def plausible_cubes(line, red, green, blue) do
    cubes = parse_cubes(line)

    Enum.all?(cubes["red"], &(&1 <= red)) &&
      Enum.all?(cubes["green"], &(&1 <= green)) &&
      Enum.all?(cubes["blue"], &(&1 <= blue))
  end

  def fewest_cubes_needed(line) do
    cubes = parse_cubes(line)
    Enum.max(cubes["red"]) * Enum.max(cubes["green"]) * Enum.max(cubes["blue"])
  end

  def parse_cubes(line) do
    ~r/(?<n>\d*) (?<type>red|green|blue)/
    |> Regex.scan(line, capture: :all_but_first)
    |> Enum.group_by(fn [_n, t] -> t end, fn [n, _t] -> String.to_integer(n) end)
  end

  def parse_input(input) do
    String.split(input, "\n", trim: true)
  end
end
