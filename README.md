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

Locations represent an x/y coordinate on the map. A Location manages its own plant growth based on its biome type, jungle, or steppes and communicates events to the PubSub Registry. The Jungle in the center of the world generates food at a faster rate than the surrounding areas.

### Animals

Animals are born with a random set of genes (used for turning) and a random name (used for linage tracking / reproduction). An animal can communicate with a Location via the World Registry to check for food. An animal will also publish its life events to the PubSub Registry.

On each tick an animal will attempt to eat. If there is no food it will try to reproduce. If it does not have enough energy for reproduction the animal will rotate (based on its genes) and move one (consuming energy). An animal will die if it runs out of energy.

When an animal reproduces, its offspring is a copy of the parent. The child will have a mutated gene and a newly generated name based on the parent's name.

### Narration

We figured out that we wanted to build a simulation first, but we also wanted to do some form of non-traditional interface.  We considered things like pixel-based output to a Raspberry Pi screen among other things, but those options felt a little out of reach for the time we had.

Instead, we decided to weave a story from the simulated events.  Each time an animal is born, a plant grows, the former eats the latter, etc. the system generates an event.  Those events can power things like our ASCII art visualizer, but they can also be molded into a story.

The narration code serves this role.  It aggregates and summarizes plant growth, it announces births and deaths, and it semi-intelligently combines an animal's activity to turn consectutive moves or meals into journeys from region to region or feasts.  Most importantly though, it injects plenty of whimsy.  For example, behold this tale of urban development:

> Rhythmic Ashy Building desperately searches for food in the central region.
> Rhythmic Ashy Building locates a meal in the jungle.
> Incalculable Lemon Building springs fully formed from the head of 
> Rhythmic Ashy Building.
> Most Ashy Building is wandering aimlessly through the central region.
> Most Ashy Building locates a meal in the jungle.
> Thousands Ashy Building springs fully formed from the head of 
> Most Ashy Building.
> Rhythmic Ashy Building desperately searches for food in the central region.
> Most Ashy Building moves a few steps to wind up essentially back where 
> they started.
> After consuming everything in sight, Most Ashy Building is ready for 
> the hard work of reproduction.
> Most Ashy Building's arm falls off and grows into another animal called 
> Colossal Ashy Building.

## What is a Fluid Views Tribune Anyways?

That's easy! We looked up each of our addresses on http://what3words.com/ and James' address was way cooler than Paul's, plus James has a better office.

James Edward Gray II james@graysoftinc.com @JEG2

James possess infinite wisdom and willpower when it comes to programming challenges giving him the ability to perform massive refactors holding everything in his brain (and a little help from the compiler).

Paul Dawson paul@into.computer @piisalie

Paul keeps his cell phone in the microwave while he sleeps and loves the sounds supervision trees make in the Autumn winds. He doesn't have the most clever solutions and usually just brute forces his way through everything.

## Credit

The simulation is inspired from an exercise in Land of Lisp:

http://landoflisp.com/

A random list of adjectives was borrowed from:

https://www.paperrater.com/page/lists-of-adjectives

A random list of nouns was borrowed from:

https://www.english-grammar-revolution.com/list-of-nouns.html
