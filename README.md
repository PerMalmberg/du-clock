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
