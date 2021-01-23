# du-clock

An analog clock for Dual Universe.

![example](https://raw.githubusercontent.com/PerMalmberg/du-clock/main/example.png "Links")

## Setup instructions

- Link elements as in the schematic. Make sure to link the hour and minute lights in ascending order and to link lights before anything else.
- Load `master.json` into the first master programming board.
- Load `slave.json` into the remaining programming boards, setting the Lua parameter `unitNumber` as per the schematic.

![Schematic](https://raw.githubusercontent.com/PerMalmberg/du-clock/main/Links.svg "Links")

### Setting the time
 
1. Activate the `Time Set Switch` 
2. Activate the `Master Programming Board`

The clock will now show the time of your local client regardless of which player activates it.

Don't turn off the transfer unit unit or you will have to redo the setup process.

### Parameters on the master board

- onColor: The color, in RGB, used when the light is on
- offColor: The color, in RGB, used when the light is off
- secondaryFillColor: The color, in RGB, used as the secondary color when in filling display mode.
- displayMode: Display mode, 0 for single light, 1 for fill.
- shutdownDistance: The distance at which to shutdown the clock to prevent hard-off if the player moves to far away. Can't be much larger than 100m as elements seem to load out at that point.

