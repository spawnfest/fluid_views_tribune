# Stories Evolved

A completely unnecessary evolution based story generator. The underlying simulation is inspired by a Land of Lisp exercise and drives events which are aggregated and described by the `StoriesEvolved.Narrator`. If you're more visual we have also included an ASCII art visualizer, provided you're running on a terminal that is large enough to support such things. We all know 80x43 is the ideal size for common use, but you may consider a terminal size of at least 120x31 for today's purposes.

## Setup

### Run

Run Dependencies: Erlang/OTP 20, ERTS 9.0

The repo includes an escript file: `./stories_evolved` which can be run provided Erlang is setup in your environment.


### Build

Build Dependencies: Elixir 1.5.2

1. Install dependencies: `mix deps.get`
1. Generate escript: `mix escript.build`


## Architecture

Locations:

Locations are GenServers that represent an x/y coordinate on the map. A Location  manages its own plant growth based on its biome type: jungle, or steppes and communicates events to the PubSub Registry.

Animals:

Animals are born with a random set of genes (used for turning) and a random name (used for linage tracking / reproduction). An animal communicates with a Location via the World Registry, and also publishes live events to the PubSub Registry.


Narration:


### Base simulation


## TODO

* [x] Build base simulation (Paul)
    * [x] Make configurable
    * [x] Manage simulation startup
    * [x] Make a process per animal
    * [x] Make a process per location
    * [x] Have location process manage plant growth
    * [x] Emit story events
* [X] Add ASCII Art visualizer (James)
* [ ] Tweak simulation
    * [ ] Add sexual reproduction
    * [ ] Add speed and/or preferred action genes
    * [ ] Have animals fight
* [X] Build a name generator (James)
    * [X] Use dictionary to form names
    * [X] Handle lineage
* [ ] Add "Story Teller" (James)
    * [X] Add flare:  "Stray Dog has finally croaked."
    * [X] Combine repative events
    * [ ] Use context (two animals arriving at the same local) to narrate
    * [ ] Enhance story with lineage
    * [ ] Comment on lifespans
* [ ] Package Up
    * [x] Release or escript
    * [x] Document what we did


## Events

* Animal born:  `{:born, name, x, y, parent_names}`
* Animal died:  `{:died, name, x, y}`
* Animal moved:  `{:moved, name, from_x, from_y, to_x, to_y}`
* Plant grown:  `{:grown, x, y, terrain}`
* Plant eaten:  `{:eaten, name, x, y, terrain}`

## Credit

The simulation is inspired from an exercise in Land of Lisp:

http://landoflisp.com/

A random list of adjectives was borrowed from:

https://www.paperrater.com/page/lists-of-adjectives

A random list of nouns was borrowed from:

https://www.english-grammar-revolution.com/list-of-nouns.html
