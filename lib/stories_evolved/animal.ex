defmodule StoriesEvolved.Animal do
  alias StoriesEvolved.Location
  use GenServer

  def start_link(state) do
    GenServer.start_link(__MODULE__, state)
  end

  def init(state) do
    {x, y} = state.location
    message_dispatch(state.pubsub, {:born, state.name, x, y, state.parents})

    :timer.send_interval(1_000, :tick)
    {:ok, state}
  end

  def handle_info(:tick, %{energy: 0, location: {x, y}} = state) do
    message_dispatch(state.pubsub, {:died, state.name, x, y})
    {:stop, :normal, state}
  end
  def handle_info(:tick, state) do
    with {:didnt_eat, state}       <- eat(state),
         {:didnt_reproduce, state} <- reproduce(state),
      do: move(state)
  end

  defp eat(%{location: {x, y}} = state) do
    state.location
    |> Location.eat
    |> case do
         :no_food  ->
           {:didnt_eat, state}
         :ate_food ->
           message_dispatch(state.pubsub, {:eaten, state.name, x, y})
           {:noreply, %{state | energy: state.energy + 80}}
       end
  end

  defp reproduce(%{energy: energy} = state) when energy >= 200 do
    new_state = %{state | energy: round(energy / 2)}

    new_animal =
      %{new_state |
        genes: modify_genes(state.genes),
        name: StoriesEvolved.NameGenerator.generate(state.name),
        parents: [state.name | state.parents]}

    {:ok, _} = Supervisor.start_child(StoriesEvolved.AnimalSupervisor, [new_animal])

    {:noreply, new_state}
  end
  defp reproduce(state) do
    {:didnt_reproduce, state}
  end

  defp move(state) do
    direction =
      state.genes
      |> Enum.reduce(&Kernel.+/2)
      |> :rand.uniform
      |> pick_angle(state.genes)
      |> Kernel.+(state.direction)
      |> rem(8)

    location =
      state
      |> move(direction)

    send_moved_message(state, location)

    {:noreply, %{state | location: location, direction: direction, energy: state.energy - 1}}
  end

  defp pick_angle(_, []) do
    0
  end
  defp pick_angle(total, [hd | _tail]) when (total - hd) < 0 do
    0
  end
  defp pick_angle(total, [hd | tail]) do
    1 + pick_angle((total - hd), tail)
  end

  defp move(%{location: {x, y}, dimensions: {w, h}}, 0) do
    {x, rem((y - 1 + h), h)}
  end
  defp move(%{location: {x, y}, dimensions: {w, h}}, 1) do
    {rem((x + 1 + w), w), rem((y - 1 + h), h)}
  end
  defp move(%{location: {x, y}, dimensions: {w, _h}}, 2) do
    {rem((x + 1 + w), w), y}
  end
  defp move(%{location: {x, y}, dimensions: {w, h}}, 3) do
    {rem((x + 1 + w), w), rem((y + 1 + h), h)}
  end
  defp move(%{location: {x, y}, dimensions: {w, h}}, 4) do
    {x, rem((y + 1 + h), h)}
  end
  defp move(%{location: {x, y}, dimensions: {w, h}}, 5) do
    {rem((x - 1 + w), w), rem((y + 1 + h), h)}
  end
  defp move(%{location: {x, y}, dimensions: {w, _h}}, 6) do
    {rem((x - 1 + w), w), y}
  end
  defp move(%{location: {x, y}, dimensions: {w, h}}, 7) do
    {rem((x - 1 + w), w), rem((y - 1 + h), h)}
  end

  defp send_moved_message(state, {to_x, to_y}) do
    {x, y} = state.location

    message_dispatch(state.pubsub, {:moved, state.name, x, y, to_x, to_y})
  end

  defp message_dispatch(registry, message) do
    Registry.dispatch(registry, :events, fn entries ->
      entries
      |> Enum.each(fn {pid, _} -> send(pid, message) end)
    end)
  end

  defp modify_genes(genes) do
    genes
    |> List.update_at(
      :rand.uniform(length(genes)),
      &(max(1, (&1 + :rand.uniform(3) - 1)))
    )
  end
end
