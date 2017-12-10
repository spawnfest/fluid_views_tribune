defmodule StoriesEvolved.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    jungle = {45, 10, 10, 10}
    height = 30
    width  = 100
    initial_count = 8

    interface =
      case output_mode() do
        :narrator_only ->
          [
            {
              StoriesEvolved.Narrator,
              {width, height, StoriesEvolved.PubSub, &IO.puts/1}
            }
          ]
        {:narrator_and_visualizer, columns} ->
          [
            {
              StoriesEvolved.Visualizer,
              {width, height, StoriesEvolved.PubSub, columns}
            },
            {
              StoriesEvolved.Narrator,
              {
                width,
                height,
                StoriesEvolved.PubSub,
                fn line -> send(StoriesEvolved.Visualizer, {:story, line}) end
              }
            }
          ]
      end

    children = [
      {Registry, keys: :unique, name: StoriesEvolved.World},
      {Registry, keys: :duplicate, name: StoriesEvolved.PubSub}
    ] ++
    interface ++
    [
      {StoriesEvolved.LocationSupervisor, [%{width: width, height: height, jungle: jungle}]},
      {StoriesEvolved.AnimalSupervisor, [ ]},
      {StoriesEvolved.AnimalSpawnTask, %{height: height, width: width, count: 8}}
    ] 

    opts = [strategy: :one_for_one, name: StoriesEvolved.Supervisor]

    Supervisor.start_link(children, opts)
  end

  defp output_mode do
    case {System.cmd("tput", ~w[cols]), System.cmd("tput", ~w[lines])} do
      {{cols, 0}, {lines, 0}} ->
        with {width, _rest} when width >= 120 <- Integer.parse(cols),
             {height, _rest} when height >= 31 <- Integer.parse(lines)do
          {:narrator_and_visualizer, width}
        else
          _error ->
            :narrator_only
        end
      _sizes ->
        :narrator_only
    end
  end
end
