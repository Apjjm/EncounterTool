## FF4FE Encounter Plotter & Finder
Tool for plotting out tables / step charts for finding encounters.

See [examples](./.examples/) for some generated paths.

### Disclaimer
This is a new WIP project, and there may still be bugs to iron out. I will probably use the charts generated here in my practice runs, but if you use the step charts from here in an actual race, then you are doing so at your own risk! There are existing, battle tested, counting tables for baron out there already!

### Getting started
 - Download godot Godot v4.3
 - Replace the map files in [./maps](./maps) with ones of your choosing
   - If you just want to plot a table on a black background, this is optional!
 - Run the main scene

### Controls
#### Camera
|Action    |Key                    |
|----------|-----------------------|
|Movement  |arrows / wasd / dpad   |
|Fast move |shift / R1             |
|Slow move |ctrl / L1              |
|Zoom in   |q / R2                 |
|Zoom out  |e / L2                 |
|Set screenshot position  |F / L3  |
|Save screenshot |G / Select / Back|
|Toggle Grid |H / Start / Menu     |

#### Plotting
|Action      |Key                      |
|------------|-------------------------|
|Add step    |space / x / A            |
|Delete step |backspace / circle / B   |
|Clear steps |c / square / X           |
|Encounter menu |triangle / M          |
|Change map  |p / R3                   |

### Using FF4FE encounter finder
If you want to use [FF4FE Encounter Finder](https://simbu95.github.io/FF4EncounterFinder/) to generate input, rather than
the stepping logic in this tool - change the visibility of `NewStepsDialog` and `OldStepsDialog` in the main scene. On first run you
will now be able to paste in grind instructions from the encounter finder.

Note: There is an inconsistency between the Mysidia encounter table from Rosa and FF4FE Encounter finder.
From my experimentation, it seems the encounter table is correct in Rosa in this case.

### Testing the encounters logic
Some example step tables have been produced using the output from FF4FE encounter finder and this tool to see if they match up.
You can see these in the [tests](./.tests/) folder

### Credits
 - Encounter calculation logic + data from Rosa: https://github.com/aexoden/rosa
 - Inspiration for encounter finder: https://simbu95.github.io/FF4EncounterFinder
