defmodule AoC.Day07 do
  @scores %{
    high_card: 0,
    pair: 1,
    two_pair: 2,
    three_of_a_kind: 3,
    full_house: 4,
    four_of_a_kind: 5,
    five_of_a_kind: 6
  }

  def part1(input) do
    input
    |> parse_input()
    |> sort_hands()
    |> Enum.with_index(1)
    |> Enum.reduce(0, fn {{_, bet}, i}, acc -> i * bet + acc end)
  end

  def part2(input) do
    input
    |> parse_input()
    |> Enum.map(&replace_js/1)
    |> sort_hands(&score_hand_2/1)
    |> Enum.with_index(1)
    |> Enum.reduce(0, fn {{_, bet}, i}, acc -> i * bet + acc end)
  end

  def sort_hands(hands, score_fn \\ &score_hand/1) do
    Enum.sort_by(hands, fn {hand, _bet} -> {Map.get(@scores, score_fn.(hand)), hand} end, &<=/2)
  end

  def sort_by_value(hand) do
    Enum.sort_by(hand, fn card -> {Enum.count(hand, &(&1 == card)), card} end, &>=/2)
  end

  def score_hand(hand) do
    hand |> sort_by_value() |> do_score_hand()
  end

  def score_hand_2(hand) do
    sorted = sort_by_value(hand)
    grouped = Enum.group_by(sorted, &(&1 == 1))
    {js, non_js} = {Map.get(grouped, true, []), Map.get(grouped, false, [])}
    sorted = Enum.map(js, fn _ -> Enum.at(non_js, 0, 1) end) ++ non_js
    do_score_hand(sorted)
  end

  def do_score_hand([x, x, x, x, x]), do: :five_of_a_kind
  def do_score_hand([x, x, x, x, _]), do: :four_of_a_kind
  def do_score_hand([x, x, x, y, y]), do: :full_house
  def do_score_hand([x, x, x, _, _]), do: :three_of_a_kind
  def do_score_hand([x, x, y, y, _]), do: :two_pair
  def do_score_hand([x, x, _, _, _]), do: :pair
  def do_score_hand([_, _, _, _, _]), do: :high_card

  def replace_js({hand, bet}) do
    {Enum.map(hand, fn n -> if n == 11, do: 1, else: n end), bet}
  end

  def parse_hand(hand) do
    hand
    |> String.codepoints()
    |> Enum.map(fn
      "T" -> 10
      "J" -> 11
      "Q" -> 12
      "K" -> 13
      "A" -> 14
      n -> String.to_integer(n)
    end)
  end

  def parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [hand, bet] = String.split(line, " ", trim: true)
      {parse_hand(hand), String.to_integer(bet)}
    end)
  end
end
