defmodule StoriesEvolved.RandomWords do
  @adjectives "priv/adjectives.txt"
  |> Path.relative_to_cwd
  |> File.stream!
  |> Enum.reduce({nil, Map.new}, fn line, {category, adjectives} ->
    word = String.trim(line)
    cond do
      String.last(word) == ":" ->
        {String.slice(word, 0..-2), adjectives}
      String.length(word) > 0 ->
        {category, Map.update(adjectives, category, [word], &[word | &1])}
      true ->
        {category, adjectives}
    end
  end)
  |> elem(1)
  @external_resource "priv/adjectives.txt"

  @nouns "priv/nouns.txt"
  |> Path.relative_to_cwd
  |> File.stream!
  |> Enum.reduce([ ], fn line, nouns ->
    word = String.trim(line)
    if String.length(word) > 0 do
      [word | nouns]
    else
      nouns
    end
  end)
  @external_resource "priv/nouns.txt"

  def adjective do
    @adjectives
    |> Map.values
    |> Enum.random
    |> Enum.random
  end

  def adjective(category) do
    @adjectives
    |> Map.fetch!(category)
    |> Enum.random
  end

  def noun do
    @nouns
    |> Enum.random
  end
end
