defmodule StoriesEvolved.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    jungle = {45, 10, 10, 10}
    height = 30
    width  = 100

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
      {StoriesEvolved.AnimalSupervisor, [ ]},
      {StoriesEvolved.AnimalSpawnTask, %{height: height, width: width, count: 8}}
    ] ++
    create_locations(height, width, jungle)

    opts = [strategy: :one_for_one, name: StoriesEvolved.Supervisor]

    Supervisor.start_link(children, opts)
  end

  def create_locations(height, width, jungle) do
    sizes = {width * height, elem(jungle, 2) * elem(jungle, 3)}

    0..(height - 1)
    |> Stream.flat_map(&(build_row(&1, width, jungle, sizes)))
    |> Enum.to_list
  end

  defp build_row(y, width, jungle, sizes) do
    0..(width - 1)
    |> Stream.map(&(build_child_spec(&1, y, jungle, sizes)))
  end

  defp build_child_spec(x, y, jungle, sizes) do
    Supervisor.child_spec(
      {StoriesEvolved.Location,
       %{coords: {x, y},
         type: type(x, y, jungle),
         sizes: sizes
       }},
      id: :"pos#{x}_#{y}"
    )
  end

  defp type(x, y, {xj, yj, h, w}) when (x >= xj and x < (xj + w))  and  (y >= yj and y < (yj + h)) do
    :jungle
  end
  defp type(_x, _y, _jungle) do
    :steppes
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
