defmodule AoC.Day09 do
  def part1(input) do
    input
    |> parse_input()
    |> Enum.reduce(0, fn line, acc -> acc + predict(line) end)
  end

  def part2(input) do
    input
    |> parse_input()
    |> Enum.reduce(0, fn line, acc -> acc + (line |> Enum.reverse() |> predict()) end)
  end

  def predict(line) do
    line
    |> diffs([line])
    |> Enum.map(&List.last/1)
    |> Enum.sum()
  end

  def diffs(line, acc) do
    res =
      line
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.map(fn [a, b] -> b - a end)

    if Enum.all?(res, fn x -> x == 0 end) do
      acc
    else
      diffs(res, [res | acc])
    end
  end

  def parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      line
      |> String.split()
      |> Enum.map(&String.to_integer/1)
    end)
  end
end
