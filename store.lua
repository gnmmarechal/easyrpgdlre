--Store script
storefrontendversion = 1
storerequiredSVer = 1
--The ZIPs for the store have a folder with the game inside. This means they'll extract the game directly to its destination directory.
--ZIPs for the location
IbZIP = "http://gs2012.xyz/3ds/easyrpgdlre/store/games/Ib.zip"
YumeNikkiZIP = "http://gs2012.xyz/3ds/easyrpgdlre/store/games/YumeNikki.zip"
flowZIP = "http://gs2012.xyz/3ds/easyrpgdlre/store/games/flow.ZIP"

--Store script
if storerun == 1 then
	storechoice = 1
	lastchoice = 3
	storerun = 1	
end

if storescr == 1 then
	storescrone()
	storeinputscr(-1,KEY_X)
	storedpad()
end

--Store Interface
function storescrone()
	storehead()
	gamelist()
end


function storehead() -- Head of all screens
	if strheadflip == 1 then
		debugWrite(0,0,"EasyRPG Games Store", white, TOP_SCREEN)
		debugWrite(0,20,"==============================", red, TOP_SCREEN)	
	end
	Screen.debugPrint(0,0,"EasyRPG Games Store", white, TOP_SCREEN)
	Screen.debugPrint(0,20,"==============================", red, TOP_SCREEN)	
end
function storedpad()
	if Controls.check(pad,KEY_DUP) and not Controls.check(oldpad,KEY_DUP) then
		storechoice = storechoice - 1
		if storechoice == -1
			storechoice = lastchoice
		end
	elseif Controls.check(pad,KEY_DDOWN) and not Controls.check(oldpad,KEY_DDOWN) then 
		storechoice = storechoice + 1
		if storechoice == lastchoice + 1 then
			storechoice = 1
		end
	end 
end

function gamelist()
	if storechoice == 1 then
		Screen.debugPrint(0,40,".flow", green, TOP_SCREEN)
	else
		Screen.debugPrint(0,40,".flow", white, TOP_SCREEN) 
	end
	if storechoice == 2 then
		Screen.debugPrint(0,60,"Ib", green, TOP_SCREEN)
	else
		Screen.debugPrint(0,60,"Ib", white, TOP_SCREEN)
	end
	if storechoice == 3 then
		Screen.debugPrint(0,80,"Yume Nikki", green, TOP_SCREEN)
	else
		Screen.debugPrint(0,80,"Yume Nikki", white, TOP_SCREEN)
	end

end

