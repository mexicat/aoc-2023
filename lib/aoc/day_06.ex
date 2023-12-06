defmodule AoC.Day06 do
  def part1(input) do
    input
    |> parse_input()
    |> Enum.map(fn {t, d} -> t |> race() |> Enum.count(fn x -> x > d end) end)
    |> Enum.product()
  end

  def part2(input) do
    {t, d} = input |> parse_input_2()
    t |> race() |> Enum.count(fn x -> x > d end)
  end

  def race(t) do
    Enum.map(1..(t - 1), fn i -> (t - i) * i end)
  end

  def parse_input(input) do
    [t, d] = input |> String.split("\n", trim: true)
    t = t |> String.split(["Time:", " "], trim: true) |> Enum.map(&String.to_integer/1)
    d = d |> String.split(["Distance:", " "], trim: true) |> Enum.map(&String.to_integer/1)
    Enum.zip(t, d)
  end

  def parse_input_2(input) do
    [t, d] = input |> String.split("\n", trim: true)
    t = t |> String.split(["Time:", " "], trim: true) |> Enum.join() |> String.to_integer()
    d = d |> String.split(["Distance:", " "], trim: true) |> Enum.join() |> String.to_integer()
    {t, d}
  end
end
