defmodule Mix.Tasks.Day do
  use Mix.Task

  @shortdoc "Run Day"
  def run(args) do
    day = Enum.at(args, 0)
    part = Enum.at(args, 1)
    benchmark? = Enum.at(args, 2) == "-b"

    input = AoC.Loader.load(day)
    module_name = String.to_atom("Elixir.AoC.Day#{day}")
    fun_name = String.to_atom("part#{part}")

    if benchmark?,
      do: Benchee.run(%{"part_#{part}": fn -> apply(module_name, fun_name, [input]) end}),
      else:
        IO.inspect(apply(module_name, fun_name, [input]),
          label: "Part #{part} results",
          charlists: :as_lists
        )
  end
end
