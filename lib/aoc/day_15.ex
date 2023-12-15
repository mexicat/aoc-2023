defmodule AoC.Day15 do
  def part1(input) do
    input |> parse_input() |> Enum.map(&hash(&1, 0)) |> Enum.sum()
  end

  def part2(input) do
    input |> parse_input() |> hashmap(%{})
  end

  def hashmap([], boxes) do
    boxes
    |> Enum.map(fn {id, box} ->
      box
      |> Enum.reverse()
      |> Enum.with_index(1)
      |> Enum.map(fn {{_, lens}, i} -> (id + 1) * i * lens end)
      |> Enum.sum()
    end)
    |> Enum.sum()
  end

  def hashmap([instr | rest], boxes) do
    {label, op} = Enum.split_while(instr, fn x -> x != ?= and x != ?- end)
    box_id = hash(label, 0)
    box = Map.get(boxes, box_id, [])

    box =
      case op do
        [?-] ->
          case Enum.find_index(box, fn {id, _} -> id == label end) do
            nil -> box
            idx -> List.pop_at(box, idx) |> elem(1)
          end

        [?=, len] ->
          len = [len] |> List.to_integer()

          case Enum.find_index(box, fn {id, _} -> id == label end) do
            nil -> [{label, len} | box]
            idx -> box |> List.replace_at(idx, {label, len})
          end
      end

    hashmap(rest, Map.put(boxes, box_id, box))
  end

  def hash([], acc), do: acc
  def hash([char | chars], acc), do: hash(chars, rem((char + acc) * 17, 256))

  def parse_input(input) do
    input |> String.trim() |> String.split(",", trim: true) |> Enum.map(&String.to_charlist/1)
  end
end
