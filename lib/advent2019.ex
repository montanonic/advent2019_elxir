defmodule Advent2019 do
  def input_file(day) do
    app = Application.get_application(__MODULE__)
    Path.join([Application.app_dir(app, "priv"), "day#{day}.txt"])
  end

  def input_lines(day) do
    input_file(day)
    |> File.stream!()
    |> Stream.map(&String.trim/1)
  end
end
