defmodule StoriesEvolved.AnimalSpawnTask do
  use Task

  def start_link(arg) do
    Task.start_link(__MODULE__, :run, [arg])
  end

  def run(animal) do
    {:ok, _} = Supervisor.start_child(StoriesEvolved.AnimalSupervisor, animal)
  end
end
