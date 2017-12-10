defmodule StoriesEvolved.CLI do
  alias StoriesEvolved.Application

  def main(argv) do
    argv
    |> parse_args
    |> start
  end

  defp parse_args(args) do
    args
    |> OptionParser.parse(switches: [])
    |> elem(0)
    |> Map.new
  end

  defp start(args) do
    Application.start([], args)
    Process.sleep(:infinity)
  end
end
