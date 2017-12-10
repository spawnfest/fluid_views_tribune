# Stories Evolved

A completely unnecessary evolution based story generator. The underlying simulation is inspired by a Land of Lisp exercise and drives events which are aggregated and described by the `StoriesEvolved.Narrator`. If you're more visual, we have also included an ASCII art visualizer, provided you're running on a terminal that is large enough to support such things. (We all know 80x43 is the ideal size for common use, but you may consider a terminal size of at least 120x31 for today's purposes.)

## Setup

### Run

Run Dependencies: Erlang/OTP 20, ERTS 9.0

The repo includes an escript file, `./stories_evolved`, which can be run provided Erlang is setup in your environment.

### Build

Build Dependencies: Elixir 1.5.2

1. Install dependencies: `mix deps.get`
2. Generate escript: `mix escript.build`

## Architecture

### Locations

Locations represent an x/y coordinate on the map. A Location manages its own plant growth based on its biome type, jungle, or steppes and communicates events to the PubSub Registry.

### Animals

Animals are born with a random set of genes (used for turning) and a random name (used for linage tracking / reproduction). An animal can communicate with a Location via the World Registry to check for food. An animal will also publish its life events to the PubSub Registry.

On each tick an animal will attempt to eat. If there is no food it will try to reproduce. If it does not have enough energy for reproduction the animal will rotate (based on its genes) and move one.

When an animal reproduces, its offspring is a copy of the parent. The child  will have a mutated gene and a newly generated name based on the parent's name.

### Narration



## Credit

The simulation is inspired from an exercise in Land of Lisp:

http://landoflisp.com/

A random list of adjectives was borrowed from:

https://www.paperrater.com/page/lists-of-adjectives

A random list of nouns was borrowed from:

https://www.english-grammar-revolution.com/list-of-nouns.html
