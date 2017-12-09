defmodule StoriesEvolved.Location do
  use GenServer

  def start_link(%{coords: {x, y} = coords, type: type, sizes: sizes}) do
    name = {:via, Registry, {StoriesEvolved.World, coords}}
    GenServer.start_link(
      __MODULE__,
      %{type: type, food: false, sizes: sizes, x: x, y: y},
      name: name
    )
  end

  def init(state) do
    :timer.send_interval(1_000, :grow_food)
    {:ok, state}
  end

  def handle_info(:grow_food, %{food: true} = state) do
    {:noreply, state}
  end
  def handle_info(:grow_food, %{type: :jungle, food: false, sizes: {_, jungle}} = state) do
    food = :rand.uniform(jungle) == 1

    if food do
      Registry.dispatch(StoriesEvolved.PubSub, :events, fn entries ->
        for {pid, _} <- entries, do: send(pid, {:grown, state.x, state.y})
      end)
    end

    {:noreply, %{state | food: food}}
  end
  def handle_info(:grow_food, %{type: :step, food: false, sizes: {world, _}} = state) do
    food = :rand.uniform(world) == 1

    if food do
      Registry.dispatch(StoriesEvolved.PubSub, :events, fn entries ->
        for {pid, _} <- entries, do: send(pid, {:grown, state.x, state.y})
      end)
    end

    {:noreply, %{state | food: food}}
  end
end
