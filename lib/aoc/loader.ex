defmodule AoC.Loader do
  def load(day, name \\ "input.txt") do
    day = String.pad_leading(day, 2, "0")

    "../inputs/day_#{day}_#{name}"
    |> Path.expand(__DIR__)
    |> File.read!()
  end
end
