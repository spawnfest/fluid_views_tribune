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

    tick = 1_000
    Process.send_after(self(), :narrate_dawn_of_time, 2 * tick)
    :timer.send_interval(3 * tick, :narrate_growth)

    {:ok, %__MODULE__{width: width, height: height, history: Map.new}}
  end

  def handle_info(
    {:born, name, _x, _y, [ ]},
    %__MODULE__{history: history} = state
  ) do
    new_history = Map.update(history, :births, [name], &[name | &1])
    {:noreply, %__MODULE__{state | history: new_history}}
  end
  def handle_info({:born, name, _x, _y, [parent_name]}, state) do
    narrate(
      "asexual_birth",
      %{name: Enum.join(name, " "), parent_name: Enum.join(parent_name, " ")}
    )
    {:noreply, state}
  end
  def handle_info(
    {:born, name, _x, _y, [parent_1_name, parent_2_name]},
    state
  ) do
    narrate(
      "sexual_birth",
      %{
        name: Enum.join(name, " "),
        parent_1_name: Enum.join(parent_1_name, " "),
        parent_2_name: Enum.join(parent_2_name, " ")
      }
    )
    {:noreply, state}
  end

  def handle_info({:died, name, _x, _y}, state) do
    narrate("death", %{name: Enum.join(name, " ")})
    {:noreply, state}
  end

  def handle_info(
    {:moved, _name, _from_x, _from_y, _to_x, _to_y},
    %__MODULE__{history: _history} = state
  ) do
    {:noreply, state}
  end

  def handle_info(
    {:grown, x, y, terrain},
    %__MODULE__{width: width, height: height, history: history} = state
  ) do
    new_history =
      history
      |> Map.update(:plants, 1, &(&1 + 1))
      |> Map.update(terrain, 1, &(&1 + 1))
      |> Map.update(region(x, y, width, height), 1, &(&1 + 1))
    {:noreply, %__MODULE__{state | history: new_history}}
  end

  def handle_info(
    {:eaten, _name, _x, _y},
    %__MODULE__{history: _history} = state
  ) do
    {:noreply, state}
  end

  def handle_info(
    :narrate_dawn_of_time,
    %__MODULE__{history: history} = state
  ) do
    births =
      history
      |> Map.get(:births, [ ])
      |> Enum.map(fn name -> Enum.join(name, " ") end)
      |> Enum.join(", ")
      |> String.replace(~r{\A(.+),\s}, "\\1 and ")

    if String.length(births) > 0 do
      narrate("dawn_of_time", %{births: births})
    end

    new_history = Map.delete(history, :births)
    {:noreply, %__MODULE__{state | history: new_history}}
  end

  def handle_info(:narrate_growth, %__MODULE__{history: history} = state) do
    plants = Map.get(history, :plants, 0)
    new_history =
      if plants < 3 do
        narrate("drought", Map.new)

        history
      else
        jungle = Map.get(history, :jungle, 0)
        steppes = Map.get(history, :steppes, 0)
        northeast = Map.get(history, :northeast, 0)
        northwest = Map.get(history, :northwest, 0)
        southeast = Map.get(history, :southeast, 0)
        southwest = Map.get(history, :southwest, 0)
        east = Map.get(history, :east, 0)
        north = Map.get(history, :north, 0)
        south = Map.get(history, :south, 0)
        west = Map.get(history, :west, 0)
        center = Map.get(history, :center, 0)
        dominant_terrain =
          cond do
            jungle > steppes * 2 -> "jungle"
            steppes > jungle * 2 -> "steppes"
            true -> "world"
          end
        dominant_region =
          cond do
            northeast > plants / 2 -> "northeast"
            northwest > plants / 2 -> "northwest"
            southeast > plants / 2 -> "southeast"
            southwest > plants / 2 -> "southwest"
            east > plants / 2 -> "east"
            north > plants / 2 -> "north"
            south > plants / 2 -> "south"
            west > plants / 2 -> "west"
            center > plants / 2 -> "central region"
            true -> nil
          end

        if dominant_region do
          narrate("regional_growth", %{dominant_region: dominant_region})
        else
          narrate("growth", %{dominant_terrain: dominant_terrain})
        end

        Map.drop(
          history,
          ~w[ plants jungle steppes
              northeast northwest southeast southwest
              north south east west center ]a
        )
      end

    {:noreply, %__MODULE__{state | history: new_history}}
  end

  defp region(x, y, width, height)
  when x < width / 4 and y < height / 4,
    do: :northeast
  defp region(x, y, width, height)
  when x > width - width / 4 and y < height / 4,
    do: :northwest
  defp region(x, y, width, height)
  when x < width / 4 and y > height - height / 4,
    do: :southeast
  defp region(x, y, width, height)
  when x > width - width / 4 and y > height - height / 4,
    do: :southwest
  defp region(_x, y, _width, height)
  when y < height / 4,
    do: :north
  defp region(_x, y, _width, height)
  when y > height - height / 4,
    do: :south
  defp region(x, _y, width, _height)
  when x < width / 4,
    do: :east
  defp region(x, _y, width, _height)
  when x > width - width / 4,
    do: :west
  defp region(_x, _y, _width, _height),
    do: :center

  defp narrate(event, details) do
    template =
      @templates
      |> Map.fetch!(event)
      |> Enum.random
    Regex.replace(
      ~r{
        \b (?:
        BIRTHS | NAME | PARENT_NAME | PARENT_1_NAME | PARENT_2_NAME |
        TERRAIN | DOMINANT_TERRAIN | DOMINANT_REGION
        ) \b
      }x,
      template,
      &(
        Map.fetch!(details, &1 |> String.downcase |> String.to_existing_atom)
        |> to_string()
      ),
      global: true
    )
    |> IO.puts
  end
end
