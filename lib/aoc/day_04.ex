defmodule AoC.Day04 do
  def part1(input) do
    input
    |> parse_input()
    |> Enum.reduce(0, fn {_, {winners, all}}, acc ->
      matches = MapSet.intersection(MapSet.new(winners), MapSet.new(all))

      case MapSet.size(matches) do
        0 -> acc
        n -> acc + Integer.pow(2, n - 1)
      end
    end)
  end

  def part2(input) do
    cards = parse_input(input)

    matches =
      Enum.reduce(cards, %{}, fn {i, {winners, all}}, acc ->
        matches = MapSet.intersection(MapSet.new(winners), MapSet.new(all))
        Map.put(acc, i, MapSet.size(matches))
      end)

    recurse_cards(Enum.to_list(1..map_size(cards)), matches, 0)
  end

  def recurse_cards([], _, acc), do: acc

  def recurse_cards([i | rest], matches, acc) do
    case Map.get(matches, i) do
      0 -> recurse_cards(rest, matches, acc + 1)
      n -> recurse_cards(Enum.to_list((i + 1)..(i + n)) ++ rest, matches, acc + 1)
    end
  end

  def parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.with_index(1)
    |> Enum.map(fn {card, i} ->
      [_, winners, all] = card |> String.split([":", "|"], trim: true)
      winners = winners |> String.split(" ", trim: true) |> Enum.map(&String.to_integer/1)
      all = all |> String.split(" ", trim: true) |> Enum.map(&String.to_integer/1)
      {i, {winners, all}}
    end)
    |> Enum.into(%{})
  end
end
