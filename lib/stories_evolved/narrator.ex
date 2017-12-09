defmodule StoriesEvolved.Narrator do
  use GenServer

  defstruct ~w[width height history]a

  @templates "priv/narration.txt"
  |> Path.relative_to_cwd
  |> File.stream!
  |> Enum.reduce({nil, Map.new}, fn line, {category, templates} ->
    template = String.trim(line)
    cond do
      String.last(template) == ":" ->
        {String.slice(template, 0..-2), templates}
      String.length(template) > 0 ->
        {
          category,
          Map.update(templates, category, [template], &[template | &1])
        }
      true ->
        {category, templates}
    end
  end)
  |> elem(1)
  @external_resource "priv/narration.txt"

  def start_link({width, height, registry}) do
    GenServer.start_link(__MODULE__, {width, height, registry})
  end

  def init({width, height, registry}) do
    Registry.register(registry, :events, nil)
    :timer.send_interval(3_000, :narrate_growth)
    {:ok, %__MODULE__{width: width, height: height, history: Map.new}}
  end

  # def handle_info(
  #   {:born, _name, x, y, _parent_names},
  #   %__MODULE__{history: history} = state
  # ) do
  #   new_history =
  #     Map.update!(history, {x, y}, &{elem(&1, 0), elem(&1, 1) + 1})
  #   {:noreply, %__MODULE__{state | history: new_history}}
  # end

  # def handle_info(
  #   {:died, _name, x, y},
  #   %__MODULE__{history: history} = state
  # ) do
  #   new_history =
  #     Map.update!(history, {x, y}, &{elem(&1, 0), elem(&1, 1) - 1})
  #   {:noreply, %__MODULE__{state | history: new_history}}
  # end

  # def handle_info(
  #   {:moved, _name, from_x, from_y, to_x, to_y},
  #   %__MODULE__{history: history} = state
  # ) do
  #   new_history =
  #     history
  #     |> Map.update!({from_x, from_y}, &{elem(&1, 0), elem(&1, 1) - 1})
  #     |> Map.update!({to_x, to_y}, &{elem(&1, 0), elem(&1, 1) + 1})
  #   {:noreply, %__MODULE__{state | history: new_history}}
  # end

  def handle_info(
    {:grown, _x, _y, terrain},
    %__MODULE__{history: history} = state
  ) do
    new_history =
      history
      |> Map.update(terrain, 1, &(&1 + 1))
    {:noreply, %__MODULE__{state | history: new_history}}
  end

  def handle_info(:narrate_growth, %__MODULE__{history: history} = state) do
    jungle = Map.get(history, :jungle, 0)
    steppes = Map.get(history, :steppes, 0)
    dominant_terrain =
      cond do
        jungle > steppes * 2 -> "jungle"
        steppes > jungle * 2 -> "steppes"
        true -> "world"
      end
    new_history = Map.drop(history, ~w[jungle steppes]a)

    narrate("growth", %{dominant_terrain: dominant_terrain})

    {:noreply, %__MODULE__{state | history: new_history}}
  end

  # def handle_info(
  #   {:eaten, _name, x, y},
  #   %__MODULE__{history: history} = state
  # ) do
  #   new_history =
  #     Map.update!(history, {x, y}, &{false, elem(&1, 1)})
  #   {:noreply, %__MODULE__{state | history: new_history}}
  # end

  defp narrate(event, details) do
    template =
      @templates
      |> Map.fetch!(event)
      |> Enum.random
    Regex.replace(
      ~r{\b(?:LAND_TYPE|DOMINANT_TERRAIN)\b},
      template,
      &expand(&1, details),
      global: true
    )
    |> IO.puts
  end

  defp expand("LAND_TYPE", %{terrain: terrain}), do: to_string(terrain)
  defp expand("DOMINANT_TERRAIN", %{dominant_terrain: dominant_terrain}) do
    dominant_terrain
  end
end
