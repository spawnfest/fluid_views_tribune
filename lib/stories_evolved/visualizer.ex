defmodule StoriesEvolved.Visualizer do
  use GenServer

  defstruct ~w[width height locations columns story_lines]a

  def start_link({width, height, registry, columns}) do
    GenServer.start_link(
      __MODULE__,
      {width, height, registry, columns},
      name: __MODULE__
    )
  end

  def init({width, height, registry, columns}) do
    tick = 1_000
    Registry.register(registry, :events, nil)
    :timer.send_interval(tick, :redraw)
    locations =
      for x <- 0..(width - 1), y <- 0..(height - 1), into: %{ } do
        {{x, y}, {false, 0}}
      end
    story_columns = columns - (width + 2)
    {
      :ok,
      %__MODULE__{
        width: width,
        height: height,
        locations: locations,
        columns: story_columns,
        story_lines:
          ""
          |> String.pad_trailing(story_columns)
          |> List.duplicate(height)
      }
    }
  end

  def handle_info(
    {:story, passage},
    %__MODULE__{columns: columns, story_lines: story_lines} = state
  ) do
    new_lines =
      passage
      |> String.replace(
        ~r<(?=.{#{columns + 1}})(.{1,#{columns - 1}})\s>,
        "\\1\n",
        global: true
      )
      |> String.split("\n")
      |> Enum.map(&String.pad_trailing(&1, columns))
      |> Enum.reverse
    new_story_lines = Enum.take(new_lines ++ story_lines, 30)
    {:noreply, %__MODULE__{state | story_lines: new_story_lines}}
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
    {:grown, x, y, _terrain},
    %__MODULE__{locations: locations} = state
  ) do
    new_locations =
      Map.update!(locations, {x, y}, &{true, elem(&1, 1)})
    {:noreply, %__MODULE__{state | locations: new_locations}}
  end

  def handle_info(
    {:eaten, _name, x, y, _terrain},
    %__MODULE__{locations: locations} = state
  ) do
    new_locations =
      Map.update!(locations, {x, y}, &{false, elem(&1, 1)})
    {:noreply, %__MODULE__{state | locations: new_locations}}
  end

  def handle_info(
    :redraw,
    %__MODULE__{
      width: width,
      height: height,
      locations: locations,
      story_lines: story_lines
    } = state
  ) do
    IO.write IO.ANSI.clear
    0..(height - 1)
    |> Enum.zip(Enum.reverse(story_lines))
    |> Enum.each(fn {y, line} ->
      [line, "  "] ++
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
