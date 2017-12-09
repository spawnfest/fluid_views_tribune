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
  def handle_info(:grow_food, %{type: :jungle, sizes: {_, jungle}} = state) do
    food = :rand.uniform(jungle) == 1

    if food, do: send_grown_message(state.x, state.y)
    {:noreply, %{state | food: food}}
  end
  def handle_info(:grow_food, %{type: :step, sizes: {world, _}} = state) do
    food = :rand.uniform(world) == 1

    if food, do: send_grown_message(state.x, state.y)
    {:noreply, %{state | food: food}}
  end

  defp send_grown_message(x, y) do
    Registry.dispatch(StoriesEvolved.PubSub, :events, fn entries ->
      entries
      |> Enum.each(fn {pid, _} -> send(pid, {:grown, x, y}) end)
    end)
  end
end
