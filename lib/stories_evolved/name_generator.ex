defmodule StoriesEvolved.NameGenerator do
  alias StoriesEvolved.RandomWords

  def generate do
    [RandomWords.adjective, RandomWords.adjective, RandomWords.noun]
    |> Enum.map(&String.capitalize/1)
  end

  def generate([_first, middle, last]) do
    [
      RandomWords.adjective,
      Enum.random([middle, RandomWords.adjective]),
      last
    ]
    |> Enum.map(&String.capitalize/1)
  end

  def generate([_first_1, middle_1, last_1], [_first_2, middle_2, last_2]) do
    if :rand.uniform(10) == 1 do
      [
        RandomWords.adjective,
        Enum.random([middle_1, middle_2]),
        [last_1, last_2] |> Enum.shuffle |> Enum.join("")
      ]
    else
      {middle, last} = Enum.random([{middle_1, last_2}, {middle_2, last_1}])
      [RandomWords.adjective, middle, last]
    end
    |> Enum.map(&String.capitalize/1)
  end
end
