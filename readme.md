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
|Encounter menu | m / triangle / Y     |
|Change map  |p / R3                   |

### Changing how it looks
 - You can change the style of the boxes drawn by increasing `box_style` on Overlay

### Using FF4FE encounter finder
If you want to use [FF4FE Encounter Finder](https://simbu95.github.io/FF4EncounterFinder/) to generate input, rather than
the stepping logic in this tool - change the visibility of `NewStepsDialog` and `OldStepsDialog` in the main scene. On first run you
will now be able to paste in grind instructions from the encounter finder.

Note: There is an inconsistency between the Mysidia encounter table from Rosa and FF4FE Encounter finder.
From my experimentation, it seems the encounter table is correct in Rosa in this case.

### Testing the encounters logic
Some example step tables have been produced using the output from FF4FE encounter finder and this tool to see if they match up.
You can see these in the [tests](./.tests/) folder

Additionally, the tool will output to the debug console the entire set of encounters for each seed in csv format (plus any sets of encounters it removed as it can't guarantee the desired encounter). You can use this output to check against other step charts more easily - note that the number for encounters needed includes the initial encounter you found (so is 1 bigger than what you see when plotting things in the tool). This output contains the number of steps needed to reach the 2nd start map encounter which is not shown directly in the tool - this could be used for manually adding in a few squares where you want to rely on step counting instead (this is best done in the early squares that you are most likely to hit). This is something the tool could look to do in the future, but it significantly complicates the logic to handle this for the general case at the moment (e.g. sometimes you want to use step counting to reject certain options instead of choosing them too!). PRs welcome.

### Credits
 - Encounter calculation logic + data from Rosa: https://github.com/aexoden/rosa
 - Inspiration for encounter finder: https://simbu95.github.io/FF4EncounterFinder
