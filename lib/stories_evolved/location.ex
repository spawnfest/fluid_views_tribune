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

  def eat(location) do
    StoriesEvolved.World
    |> Registry.lookup(location)
    |> List.first
    |> elem(0)
    |> GenServer.call({:eat})
  end

  def handle_call({:eat}, _from, %{food: false} = state) do
    {:reply, :no_food, state}
  end
  def handle_call({:eat}, _from, %{food: true} = state) do
    {:reply, :ate_food, %{state | food: false}}
  end

  def handle_info(:grow_food, %{food: true} = state) do
    {:noreply, state}
  end
  def handle_info(:grow_food, %{type: :jungle, sizes: {_, jungle}} = state) do
    food = :rand.uniform(jungle) == 1

    if food, do: send_grown_message(state.x, state.y, :jungle)
    {:noreply, %{state | food: food}}
  end
  def handle_info(:grow_food, %{type: :steppes, sizes: {world, _}} = state) do
    food = :rand.uniform(world) == 1

    if food, do: send_grown_message(state.x, state.y, :steppes)
    {:noreply, %{state | food: food}}
  end

  defp send_grown_message(x, y, type) do
    Registry.dispatch(StoriesEvolved.PubSub, :events, fn entries ->
      entries
      |> Enum.each(fn {pid, _} -> send(pid, {:grown, x, y, type}) end)
    end)
  end
end
