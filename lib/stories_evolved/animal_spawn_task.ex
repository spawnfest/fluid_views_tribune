defmodule StoriesEvolved.AnimalSpawnTask do
  use Task

  def start_link(arg) do
    Task.start_link(__MODULE__, :run, [arg])
  end

  def run(%{height: height, width: width, count: count}) do
    Stream.repeatedly(fn ->
      %{
        location: {:rand.uniform(width) - 1, :rand.uniform(height) - 1},
        dimensions: {width, height},
        name: StoriesEvolved.NameGenerator.generate,
        direction: :rand.uniform(8) - 1,
        genes: initial_genes,
        pubsub: StoriesEvolved.PubSub,
        world: StoriesEvolved.World,
        energy: 125
  }
    end)
    |> Enum.take(count)
    |> Enum.each(&(
          {:ok, _} = Supervisor.start_child(StoriesEvolved.AnimalSupervisor, [&1])
        ))
  end

  defp initial_genes do
    Stream.repeatedly(fn -> :rand.uniform(10) end) |> Enum.take(8)
  end
end
