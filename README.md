# Stories Evolved

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
    * [ ] Release or escript
    * [ ] Document what we did

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
