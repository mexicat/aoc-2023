defmodule AoC.Day05 do
  def part1(input) do
    {seeds, stages} = input |> parse_input()

    Enum.map(seeds, fn seed -> map_stage(seed, stages) end)
    |> Enum.min()
  end

  def part2(input) do
    {seeds, stages} = input |> parse_input()

    seeds =
      seeds
      |> Enum.chunk_every(2)
      |> Enum.map(fn [x, y] ->
        x..(x + y - 1)
      end)

    Enum.map(seeds |> Enum.with_index(), fn {rng, i} ->
      Enum.reduce(rng, :infinity, fn seed, acc ->
        case map_stage(seed, stages) do
          n when n < acc -> n
          _ -> acc
        end
      end)
    end)
    |> Enum.min()
  end

  def map_stage(seed, []), do: seed

  def map_stage(seed, [stage | stages]) do
    case Enum.find(stage, fn {src, _, _} -> seed in src end) do
      nil ->
        map_stage(seed, stages)

      {_, dst, _rng} ->
        r = seed - dst
        map_stage(r, stages)
    end
  end

  def parse_input(input) do
    [seeds | rest] = input |> String.split("\n\n", trim: true)
    seeds = seeds |> String.split(["seeds: ", " "], trim: true) |> Enum.map(&String.to_integer/1)

    r =
      Enum.map(rest, fn section ->
        [_ | rest] = String.split(section, [": ", "\n"], trim: true)

        Enum.map(rest, fn line ->
          [dst, src, rng] =
            line |> String.split(" ", trim: true) |> Enum.map(&String.to_integer/1)

          {src..(src + rng - 1), src - dst, rng}
        end)
      end)

    {seeds, r}
  end
end
