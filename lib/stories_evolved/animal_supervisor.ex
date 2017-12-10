defmodule StoriesEvolved.AnimalSupervisor do
  alias StoriesEvolved.Animal

  def child_spec(args) do
    %{
      id:    __MODULE__,
      start: {__MODULE__, :start_link, args},
      type:  :supervisor
    }
  end

  def start_link do
    Supervisor.start_link(
      [base_spec()],
      strategy: :simple_one_for_one,
      name:     __MODULE__
    )
  end

  defp base_spec do
    Supervisor.child_spec(
      Animal,
      restart: :transient,
      start:   {Animal, :start_link, [ ]}
    )
  end
end
