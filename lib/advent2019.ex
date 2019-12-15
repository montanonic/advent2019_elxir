defmodule Advent2019 do
  def input_file(module) do
    app = Application.get_application(__MODULE__)

    Path.join([
      Application.app_dir(app, "priv"),
      "#{inspect(module) |> String.downcase()}.txt"
    ])
  end

  def input_lines(module) do
    input_file(module)
    |> File.stream!()
    |> Stream.map(&String.trim/1)
  end
end
