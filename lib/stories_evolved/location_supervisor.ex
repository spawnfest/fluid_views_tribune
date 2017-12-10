defmodule StoriesEvolved.LocationSupervisor do
  def child_spec(args) do
    %{
      id:    __MODULE__,
      start: {__MODULE__, :start_link, args},
      type:  :supervisor
    }
  end

  def start_link(opts) do
    children = create_locations(opts.height, opts.width, opts.jungle)

    Supervisor.start_link(children, strategy: :one_for_one, name: __MODULE__)
  end

  defp create_locations(height, width, jungle) do
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
end
