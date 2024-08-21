### This project is a WIP - use these step charts in actual races at your own risk!

These examples are loops that can be walked, use the nearby terrain as reference.

 - Reset and load a save with encounters on, starting at "start"
 - When you get an encounter:
    - If a cell was orange, reset
    - If a cell is yellow with a ?
      - Run from this encounter, and then an additional X times using the number after the ?
      - e.g. `? 2` would mean run from your initial encounter, then 2 more encounters. Your goal encounter will be on the next encounter.
    - If a cell is yellow with some letters
      - If your encounter matches one of the labelled encounters, follow the instructions above with the number next to the letters.
      - If your encounter doesn't match, reset
      - e.g. `AB 2` would mean run from 2 additional encounters, if the formation you see right now matches formation `A` or `B`. If it is something else, reset. 
 - After running from the last encounter turn off encounters immediately.

Note that encounters that appear in different "slots" in different locations (e.g. d. machin), the letters within the cell will be color coded to tell you what location to use.
