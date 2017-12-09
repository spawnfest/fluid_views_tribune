defmodule StoriesEvolved.Visualizer do
  use GenServer

  defstruct ~w[width height locations]a

  def start_link({width, height, registry}) do
    start_link({width, height, registry, 1_000})
  end
  def start_link({width, height, registry, tick}) do
    GenServer.start_link(__MODULE__, {width, height, registry, tick})
  end

  def init({width, height, registry, tick}) do
    Registry.register(registry, :events, nil)
    :timer.send_interval(tick, :redraw)
    locations =
      for x <- 0..(width - 1), y <- 0..(height - 1), into: %{ } do
        {{x, y}, {false, 0}}
      end
    {:ok, %__MODULE__{width: width, height: height, locations: locations}}
  end

  def handle_info(
    {:born, _name, x, y, _parent_names},
    %__MODULE__{locations: locations} = state
  ) do
    new_locations =
      Map.update!(locations, {x, y}, &{elem(&1, 0), elem(&1, 1) + 1})
    {:noreply, %__MODULE__{state | locations: new_locations}}
  end

  def handle_info(
    {:died, _name, x, y},
    %__MODULE__{locations: locations} = state
  ) do
    new_locations =
      Map.update!(locations, {x, y}, &{elem(&1, 0), elem(&1, 1) - 1})
    {:noreply, %__MODULE__{state | locations: new_locations}}
  end

  def handle_info(
    {:moved, _name, from_x, from_y, to_x, to_y},
    %__MODULE__{locations: locations} = state
  ) do
    new_locations =
      locations
      |> Map.update!({from_x, from_y}, &{elem(&1, 0), elem(&1, 1) - 1})
      |> Map.update!({to_x, to_y}, &{elem(&1, 0), elem(&1, 1) + 1})
    {:noreply, %__MODULE__{state | locations: new_locations}}
  end

  def handle_info(
    {:grown, x, y},
    %__MODULE__{locations: locations} = state
  ) do
    new_locations =
      Map.update!(locations, {x, y}, &{true, elem(&1, 1)})
    {:noreply, %__MODULE__{state | locations: new_locations}}
  end

  def handle_info(
    {:eaten, _name, x, y},
    %__MODULE__{locations: locations} = state
  ) do
    new_locations =
      Map.update!(locations, {x, y}, &{false, elem(&1, 1)})
    {:noreply, %__MODULE__{state | locations: new_locations}}
  end

  def handle_info(
    :redraw,
    %__MODULE__{width: width, height: height, locations: locations} = state
  ) do
    IO.write IO.ANSI.clear
    Enum.each(0..(height - 1), fn y ->
      Enum.map(0..(width - 1), fn x ->
        case Map.fetch!(locations, {x, y}) do
          {_has_plant?, animals} when animals > 1 -> "#"
          {_has_plant?, 1} -> "@"
          {true, _animals} -> "*"
          {false, _animals} -> " "
        end
      end)
      |> IO.puts
    end)
    {:noreply, state}
  end
end
