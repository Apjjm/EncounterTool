## Examples

<details>
<summary>Baron D Machin</summary>

![](baron-dmachin.png "Baron D Machin")
</details>
<details>
<summary>Baron Mac Giant</summary>

![](baron-macgiant.png "Baron Mac Giant")
</details>
<details>
<summary>Mysidia D Machin</summary>

![](mysidia-dmachin.png "Mysidia D Machin")
</details>
<details>
<summary>Mysidia Mac Giant</summary>

![](mysidia-macgiant.png "Mysidia Mac Giant")
</details>
<details>
<summary>Mysidia Reaction</summary>

![](mysidia-reaction.png "Mysidia Reaction")
</details>
<details>
<summary>Mysidia Warlock</summary>

![](mysidia-warlock.png "Mysidia Warlock")
</details>
<details>
<summary>Mysidia King-Ryu</summary>

![](mysidia-kingryu.png "Mysidia King-Ryu")
</details>

## Usage
This project is a WIP. Use these step charts in actual races at your own risk!

These examples are loops that can be walked
 - Encounters on, stand on "start"
 - Save + Reset
 - Start walking the route / loop
 - When you get an encounter on a cell with an x, reset
 - When you get an encounter on a dark cell:
    - If the cell has a ?
      - Run from this encounter, and then an additional X times using the number after the ?
      - e.g. `? 2` would mean run from your initial encounter, then 2 more encounters. Your goal encounter will be on the next encounter.
    - If the call has some letters
        - If your encounter does not match one of the lettered encounters for this cell, reset
        - Take an additional X encounters using the number after the ?
    - Your goal encounter will be in location with the color of the text in the box.
    - After running from the last encounter turn off encounters immediately and head to the location

It is helpful to identify bits of nearby terrain to find your reference square quickly.