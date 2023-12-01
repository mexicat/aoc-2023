defmodule Mix.Tasks.InitDay do
  use Mix.Task

  @shortdoc "Fetch input and write empty file for the specified day"

  def run(args) do
    day = hd(args)
    fetch_input(day)
    write_day_file(day)
  end

  defp fetch_input(day) do
    url = "https://adventofcode.com/2023/day/#{day}/input"
    cookie = Application.fetch_env!(:aoc, :cookie)
    file = Path.expand("../../inputs/day_#{String.pad_leading(day, 2, "0")}_input.txt", __DIR__)

    IO.puts("Downloading from #{url}...")
    HTTPoison.start()
    %HTTPoison.Response{body: body} = HTTPoison.get!(url, %{}, hackney: [cookie: [cookie]])

    if File.exists?(file) do
      IO.puts("File exists, will overwrite...")
    end

    IO.puts("Writing file...")
    File.write!(file, body)

    IO.puts("Done.")
  end

  defp write_day_file(day) do
    file = Path.expand("../../aoc/day_#{String.pad_leading(day, 2, "0")}.ex", __DIR__)

    if File.exists?(file) do
      IO.puts("Day file already exists, not creating.")
    else
      IO.puts("Creating day file...")
      File.write!(file, day_file_contents(day))
    end
  end

  defp day_file_contents(day) do
    """
    defmodule AoC.Day#{String.pad_leading(day, 2, "0")} do
      def part1(input) do
      end

      def part2(input) do
      end
    end
    """
  end
end
