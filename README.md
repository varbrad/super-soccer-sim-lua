##Super Soccer Sim
**Super Soccer Sim** is a project I originally started under the boring name *Football Simulation*. The project was initially a fun little game that I made to learn more about Lua and the LÖVE framework in particular. It became a fun little timewaster to simulate through seasons of football and generate semi-realistic results.

Ultimately, the codebase for the project got very messy (it was my first Lua game after all!), and as I wished to make changes to the way the textures were managed in memory, it proved difficult with the restrictive *State* system in place. On top of that, much of the *Skin* data was not properly standardised and things got a bit out of control.

###Controls
+ **Escape** - Quits the game
+ **F1** - Team Overview
+ **F2** - League Overview
+ **F3** - Full League Table
+ **F4** - League Result Grid
+ **F5** - League Past Winners
+ **F6** - League Stats (Currently blank)
+ **F7** - Team History
+ **F12** - Take a Screenshot (Saved in %AppData%/SuperSoccerSim/screenshots)
+ **Space** - Advance the Week (Continue into next season if week is 52)
+ **z** - Skip to next season (Will simulate rest of current season)
+ **l** - Sets current team as active team (Must be on Team Overview screen)
+ **Up-Down** - Cycles through teams and leagues - Up & down league position, Up & down league pyramid
+ **Left-Right** - Cycles through teams and league depending on context (database ID's for now)

###How to use a database file (.sssdb [for now])
- Run the game at least once to generate the save folder.
- Download a database from the Releases section.
- Navigate to the save folder, this will be in either; "%AppData%/LOVE/SuperSoccerSim" or "%AppData%/SuperSoccerSim".
- Create a new folder called "db" if it does not exist.
- Place the database file (.sssdb) inside the "db" folder.
- Run the game and the database should be ready to play!

###How to use custom logos
- Run the game at least once to generate the save folder.
- Download a logo pack.
- Navigate to the save folder, this will be in either; "%AppData%/LOVE/SuperSoccerSim" or "%AppData%/SuperSoccerSim".
- Create a new folder called "assets" if it does not exist.
- Extract the logo pack into the "assets" folder.
- Your directory structure should look something like "assets/images/logos/", with many files inside.
- Run/restart the game and the logos will automatically be applied!

###Plans
+ **Remove unnecessary leagues and teams**. At least until the project is ready for them. Maintaining the long list of teams and leagues in the program slows everything down. It will be much easier to add them back in later on.
+ **Use either .dds or .png images**. Give the user the option to use default images or compressed images.
+ **Include multiple seasons, with promotion and relegation.** Something I never got round to adding in the previous iteration.
+ **Spruce up the whole thing!** I am redesigning the UI to look a bit nicer and be more user-friendly.