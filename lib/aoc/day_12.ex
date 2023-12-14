defmodule AoC.Day12 do
  # memoization agent
  defmodule Memo do
    use Agent

    def start() do
      Agent.start_link(fn -> %{} end)
    end

    def stop(pid) do
      Agent.stop(pid)
    end

    def get(pid, key) do
      Agent.get(pid, fn state -> Map.get(state, key) end)
    end

    def set(pid, key, value) do
      Agent.update(pid, fn state -> Map.put(state, key, value) end)
    end
  end

  def part1(input) do
    {:ok, pid} = Memo.start()

    res =
      input
      |> parse_input()
      |> Enum.map(fn {str, springs} ->
        validate(str, [], false, springs, pid)
      end)
      |> Enum.sum()

    Memo.stop(pid)

    res
  end

  def part2(input) do
    input
    |> parse_input()
    |> Task.async_stream(
      fn {str, springs} ->
        {:ok, pid} = Memo.start()
        str = List.duplicate(str, 5) |> Enum.join("?") |> String.codepoints()
        springs = List.duplicate(springs, 5) |> List.flatten()
        res = validate(str, [], false, springs, pid)
        Memo.stop(pid)
        res
      end,
      ordered: false,
      timeout: :infinity
    )
    |> Stream.map(&elem(&1, 1))
    |> Enum.sum()
  end

  def validate([], acc, false, acc, pid), do: 1

  def validate([], acc, n, springs, pid) when n != false,
    do: validate([], acc ++ [n], false, springs, pid)

  def validate([], _, _, _, _), do: 0

  def validate(chars, acc, state, springs, pid) do
    case Memo.get(pid, {chars, acc, state, springs}) do
      nil ->
        acc
        |> Stream.zip(springs)
        |> Enum.reduce_while(true, fn
          {a, a}, _ -> {:cont, true}
          _, _ -> {:halt, false}
        end)
        |> case do
          true ->
            n = do_validate(chars, acc, state, springs, pid)
            Memo.set(pid, {chars, acc, state, springs}, n)
            n

          false ->
            Memo.set(pid, {chars, acc, state, springs}, 0)
            0
        end

      n ->
        n
    end
  end

  def do_validate(["#" | rest], acc, false, springs, pid),
    do: validate(rest, acc, 1, springs, pid)

  def do_validate(["#" | rest], acc, n, springs, pid),
    do: validate(rest, acc, n + 1, springs, pid)

  def do_validate(["." | rest], acc, false, springs, pid),
    do: validate(rest, acc, false, springs, pid)

  def do_validate(["." | rest], acc, n, springs, pid),
    do: validate(rest, acc ++ [n], false, springs, pid)

  def do_validate(["?" | rest], acc, state, springs, pid) do
    validate(["#" | rest], acc, state, springs, pid) +
      validate(["." | rest], acc, state, springs, pid)
  end

  def do_validate(_, _, _, _, _), do: 0

  def parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [a | b] = String.split(line, [" ", ","], trim: true)
      {String.codepoints(a), Enum.map(b, &String.to_integer/1)}
    end)
  end
end
