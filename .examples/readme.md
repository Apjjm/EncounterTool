## Examples
Note: This project is a WIP. Use these step charts in actual races at your own risk, especially if you haven't tested them in a practice seed first!
Charts marked with a ✔ I have used a few times in a practice seed.


### Baron

<details>
<summary>D Machin</summary>

![](baron-dmachin.png "Baron D Machin")
</details>
<details>
<summary>Mac Giant</summary>

![](baron-macgiant.png "Baron Mac Giant")
</details>

### Mysidia

<details>
<summary>D Machin</summary>

![](mysidia-dmachin.png "Mysidia D Machin")
</details>
<details>
<summary>Mac Giant (✔)</summary>

![](mysidia-macgiant.png "Mysidia Mac Giant")
</details>
<details>
<summary>Reaction</summary>

![](mysidia-reaction.png "Mysidia Reaction")
</details>
<details>
<summary>Warlock</summary>

![](mysidia-warlock.png "Mysidia Warlock")
</details>
<details>
<summary>King-Ryu</summary>

![](mysidia-kingryu.png "Mysidia King-Ryu")
</details>

### Lunar

<details>
<summary>D Machin</summary>

![](lunar-dmachin.png "Lunar D Machin")
</details>
<details>
<summary>Mac Giant</summary>

![](lunar-macgiant.png "Lunar Mac Giant")
</details>
<details>
<summary>Reaction</summary>

![](lunar-reaction.png "Lunar Reaction")
</details>
<details>
<summary>Warlock</summary>

![](lunar-warlock.png "Lunar Warlock")
</details>
<details>
<summary>King-Ryu</summary>

![](lunar-kingryu.png "Lunar King-Ryu")
</details>

### Other

<details>
<summary>Lilith (any formation) (Ordeals)</summary>

![](ordeals-lilith.png "Ordeals Lilith")
</details>


## Usage
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