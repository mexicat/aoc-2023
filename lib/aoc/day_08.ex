defmodule AoC.Day08 do
  def part1(input) do
    {dirs, nodes} = input |> parse_input()

    find_end("AAA", dirs, nodes)
  end

  def part2(input) do
    {dirs, nodes} = input |> parse_input()

    nodes
    |> Enum.filter(fn {k, _} -> String.ends_with?(k, "A") end)
    |> Enum.map(fn {k, _} -> k end)
    |> Enum.map(fn start -> find_end(start, dirs, nodes) end)
    |> lcm()
  end

  def find_end(start, dirs, nodes) do
    dirs
    |> Stream.cycle()
    |> Enum.reduce_while({start, 0}, fn dir, {curr, steps} ->
      node = nodes[curr]
      next = node[dir]

      case String.ends_with?(next, "Z") do
        true -> {:halt, steps + 1}
        false -> {:cont, {next, steps + 1}}
      end
    end)
  end

  def parse_input(input) do
    [dirs, nodes] = input |> String.split("\n\n", trim: true)

    dirs = dirs |> String.codepoints() |> Enum.map(&String.to_atom/1)

    nodes =
      nodes
      |> String.split("\n", trim: true)
      |> Enum.map(fn line ->
        [node, l, r] = String.split(line, [" = (", ", ", ")"], trim: true)
        {node, %{L: l, R: r}}
      end)
      |> Enum.into(%{})

    {dirs, nodes}
  end

  def gcd(a, 0), do: a
  def gcd(0, b), do: b
  def gcd(a, b), do: gcd(b, rem(a, b))

  def lcm(0, 0), do: 0
  def lcm(a, b), do: div(a * b, gcd(a, b))
  def lcm(list), do: Enum.reduce(list, 1, fn x, acc -> lcm(x, acc) end)
end
