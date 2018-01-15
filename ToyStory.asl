state("higan"){}
state("snes9x"){}
state("snes9x-x64"){}

startup
{

}

//init and emulator memory offsets found in https://raw.githubusercontent.com/Spiraster/ASLScripts/master/LiveSplit.SMW/LiveSplit.SMW.asl

init
{
	int memoryOffset = 0;
	while (memoryOffset == 0)
	{
		switch (modules.First().ModuleMemorySize)
		{
			case 5914624: //snes9x (1.53)
				memoryOffset = memory.ReadValue<int>((IntPtr)0x6EFBA4);
				break;
			case 6909952: //snes9x (1.53-x64)
				memoryOffset = memory.ReadValue<int>((IntPtr)0x140405EC8);
				break;
			case 6447104: //snes9x (1.54.1)
				memoryOffset = memory.ReadValue<int>((IntPtr)0x7410D4);
				break;
			case 7946240: //snes9x (1.54.1-x64)
				memoryOffset = memory.ReadValue<int>((IntPtr)0x1404DAF18);
				break;
			case 6602752: //snes9x (1.55)
				memoryOffset = memory.ReadValue<int>((IntPtr)0x762874);
				break;
			case 8355840: //snes9x (1.55-x64)
				memoryOffset = memory.ReadValue<int>((IntPtr)0x1405BFDB8);
				break;
			case 12509184: //higan (v102)
				memoryOffset = 0x915304;
				break;
			case 13062144: //higan (v103)
				memoryOffset = 0x937324;
				break;
			case 15859712: //higan (v104)
				memoryOffset = 0x952144;
				break;
			case 16756736: //higan (v105tr1)
				memoryOffset = 0x94F144;
				break;
			case 16019456: //higan (v106)
				memoryOffset = 0x94D144;
				break;
			default:
				memoryOffset = 1;
				break;
		}
	}

	vars.watchers = new MemoryWatcherList
	{
    new MemoryWatcher<byte>((IntPtr)memoryOffset + 0x2951) { Name = "Startgame" },
		new MemoryWatcher<byte>((IntPtr)memoryOffset + 0x001A) { Name = "Currentlevel" }, //Thanks to Enmet for this address
		new MemoryWatcher<byte>((IntPtr)memoryOffset + 0x1802) { Name = "Buzzcontrol" },
	};
}

update
{
	vars.watchers.UpdateAll(game);
}

start
{
	return vars.watchers["Startgame"].Old == 0 && vars.watchers["Startgame"].Current == 0x80; //Split when Start game is pressed
}

reset
{
  var toTitlelevel = vars.watchers["Currentlevel"].Old != vars.watchers["Currentlevel"].Current && vars.watchers["Currentlevel"].Current == 0x2A; //This resets the timer as soon as the Menu options are shown (after Press Start)
  var startCanceled = vars.watchers["Startgame"].Old == 0x80 && vars.watchers["Startgame"].Current == 0 && vars.watchers["Currentlevel"].Current == 0x2A; //Needed in case the game is reset before the first level starts

  return toTitlelevel || startCanceled;
}

split
{
	var levelComplete = vars.watchers["Currentlevel"].Old != vars.watchers["Currentlevel"].Current && vars.watchers["Currentlevel"].Old != 0x2A; //Split as soon as Level complete fades out
	var finalSplit = vars.watchers["Currentlevel"].Current == 0x10 && vars.watchers["Buzzcontrol"].Old == 0x7E && vars.watchers["Buzzcontrol"].Current == 0x7F; //Split when control of Buzz is lost in the Final level

	return levelComplete || finalSplit;
}
