defmodule AoC.Day13 do
  def part1(input) do
    input = input |> parse_input()

    Enum.map(input, fn pattern ->
      case find_reflection(pattern) do
        [] ->
          [{_i1, i2}] = find_reflection(verticalize(pattern))
          i2

        [{_i1, i2}] ->
          i2 * 100
      end
    end)
    |> Enum.sum()
  end

  def part2(input) do
    input = input |> parse_input()
    found = Enum.map(input, &reflection/1)

    input
    |> Enum.with_index()
    |> Enum.map(fn {pattern, n} ->
      str = Enum.join(pattern, "\n") |> String.codepoints()

      Enum.reduce_while(str, 0, fn
        "\n", i ->
          {:cont, i + 1}

        x, i ->
          repl = if x == "#", do: ".", else: "#"
          new_str = str |> List.replace_at(i, repl) |> Enum.join() |> String.split("\n")
          existing = Enum.at(found, n)
          new_refl = reflection(new_str, existing)

          if new_refl == nil do
            {:cont, i + 1}
          else
            {:halt, new_refl}
          end
      end)
    end)
    |> Enum.sum()
  end

  def reflection(pattern, exclude \\ nil) do
    refls =
      find_reflection(pattern)
      |> Enum.map(fn {_i1, i2} -> i2 * 100 end)
      |> Enum.filter(&(&1 != exclude))

    refls =
      if length(refls) == 0 do
        find_reflection(verticalize(pattern))
        |> Enum.map(fn {_i1, i2} -> i2 end)
        |> Enum.filter(&(&1 != exclude))
      else
        refls
      end

    case length(refls) do
      0 -> nil
      1 -> List.first(refls)
      # sanity check
      x -> raise "too many reflections: #{x}"
    end
  end

  def verticalize(str) do
    str
    |> Enum.map(&String.codepoints/1)
    |> Enum.zip()
    |> Enum.map(fn x -> x |> Tuple.to_list() |> Enum.join() end)
  end

  def find_reflection(pattern) do
    pattern
    |> Enum.with_index()
    |> Enum.chunk_by(fn {c, _} -> c end)
    |> Enum.filter(&(length(&1) > 1))
    |> Enum.flat_map(fn chunk ->
      Enum.chunk_every(chunk, 2, 1, :discard)
    end)
    |> Enum.map(fn [{a, i1}, {b, i2}] ->
      case test_reflection(pattern, i1 - 1, i2 + 1) do
        true -> {i1, i2}
        false -> nil
      end
    end)
    |> Enum.filter(&(&1 != nil))
  end

  def test_reflection(_pattern, i1, _i2) when i1 < 0, do: true

  def test_reflection(pattern, i1, i2) do
    {a, b} = {Enum.at(pattern, i1), Enum.at(pattern, i2)}

    cond do
      a == nil or b == nil -> true
      a == b -> test_reflection(pattern, i1 - 1, i2 + 1)
      true -> false
    end
  end

  def parse_input(input) do
    input
    |> String.split("\n\n", trim: true)
    |> Enum.map(&String.split/1)
  end
end
