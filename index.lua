--Rewrite of the EasyRPG Updater Script. This can be easily adapted to updating other apps instead of EasyRPG.
--Author: gnmmarechal
--Runs on Lua Player Plus 3DS
--On this version of the Updater Script, more of the code is server-hosted. For example, the location from where the app is downloaded is now obtained from a text file on a server. This makes it unnecessary to update the app to get latest URLs

--Some variables
System.currentDirectory("/")
root = System.currentDirectory()
consolehbdir = root.."3ds/"
consoleerror = 0
scr = 1
oldpad = Controls.read()
debugmode = 1

--App details
versionmajor = 2
versionminor = 0
versionrev = 1
versionstage = "Alpha" --Alpha, Beta, Nightly, RC (Release Candidate), Stable, etc
versionstring = versionmajor.."."..versionminor.."."..versionrev.." "..versionstage
versionrelno = 1
selfname = "easyrpgdlre"
selfpath = consolehbdir..selfname.."/"
selfexepath = selfpath..selfname..".3dsx"
selfstring = "EasyRPG Updater : RE v."..versionstring
selfauthor = "gnmmarechal"

--Affected app details
appname = "EasyRPG 3DS"
appinstallname = "easyrpg-player"
appinstallpath = consolehbdir..appinstallname.."/"
appexepath = appinstallpath..appinstallname..".3dsx"
appsmdhpath = appinstallpath..appinstallname..".smdh"
appxmlpath = appinstallpath..appinstallname..".xml"
downloadedexe = selfpath..appinstallname..".3dsx"
downloadedsmdh = selfpath..appinstallname..".smdh"
downloadedzip = selfpath..appinstallname..".zip"

--Server strings (some vars are declared by functions after reading the strings from the server)
serverpath = "http://gs2012.xyz/3ds/"..selfname.."/"

servergetexepath = serverpath.."3dsx.txt"
servergetsmdhpath = serverpath.."smdh.txt"
servergetcommit = serverpath..appinstallname..".txt"
servergetjenkinslast = serverpath.."jenkins.txt"
servergetjenkinsstable = serverpath.."jenkinsstable.txt"
servergetjenkinsver = serverpath.."jenkinsver.txt"
servergetjenkinsverstable = serverpath.."jenkinsverstable.txt"

--serverexepath = serverpath..appinstallname..".3dsx"
--serversmdhpath = serverpath..appinstallname..".smdh"


-- Colours
white = Color.new(255,255,255)
green = Color.new(0,240,32)
red = Color.new(255,0,0)

-- Store variables
storeserverpath = "http://gs2012.xyz/3ds/"..selfname.."/store/"
serverstorescriptpath = storeserverpath.."store.lua"
storescriptpath = selfpath.."store.lua"
storerun = 0
storechoice = 1
lastchoice = 4
YumeNikkiZIP = "http://gs2012.xyz/3ds/easyrpgdlre/store/games/YumeNikki.zep"
flowZIP = "http://gs2012.xyz/3ds/easyrpgdlre/store/games/flow.zep"
IbZIP = "http://gs2012.xyz/3ds/easyrpgdlre/store/games/Ib.zep"
TestGameThreeZIP = "http://gs2012.xyz/3ds/easyrpgdlre/store/games/TestGame2003.zep" 
TestGameZIP = "http://gs2012.xyz/3ds/easyrpgdlre/store/games/TestGame2000.zep"
gamezip = selfpath.."game.zip"
onstore = 1
storeclear = 0

-- Server/network functions
function iswifion()
	if (Network.isWifiEnabled()) then
		return 1
	else
		consoleerror = 1
		scr = 0
		return 0
	end	
end


function servergetVars()
	if iswifion() == 1 then
		serverexepath = Network.requestString(servergetexepath)
		serversmdhpath = Network.requestString(servergetsmdhpath)
		servercommit = Network.requestString(servergetcommit) --Deprecated as of 1.0.1
		serverjenkinslast = Network.requestString(servergetjenkinslast) --gets the URL for the ZIP of the latest Jenkins build
		serverjenkinsstable = Network.requestString(servergetjenkinsstable)
		serverjenkinsver = Network.requestString(servergetjenkinsver) --gets the build number from Jenkins
		serverjenkinsbuild = Network.requestString(serverjenkinsver) --gets the build number from Jenkins.
		serverjenkinsverstable = Network.requestString(servergetjenkinsverstable)
		serverjenkinsbuildstable = Network.requestString(serverjenkinsverstable)
	end
end

--System functions
function clear()

	Screen.refresh()
	Screen.clear(TOP_SCREEN)
	Screen.clear(BOTTOM_SCREEN)
end 

function flip()
	Screen.flip()
	Screen.waitVblankStart()
	oldpad = pad
end
function waitloop()
	loop = 0
end
function quit()
	System.exit()
end

function runoncevars()
	--gotvars = 0
	checkedicon = 0
	if System.getModel() == 2 or System.getModel() == 4 then
		System.setCpuSpeed(NEW_3DS_CLOCK)
	end	
end
updated = 0
skipped = 0
--Input functions
function inputscr(newscr, inputkey)
	if Controls.check(pad,inputkey) and not Controls.check(oldpad,inputkey) then
		if newscr == -1 then
			quit()
		end
		Screen.clear(TOP_SCREEN)
		scr = newscr
	end	
end

function nextscr(skrin)
	
	inputscr(skrin, KEY_A)
end

function checkquit()
	inputscr(-1, KEY_B)
end

function checkrestart()
	inputscr(-3, KEY_R)
end

function endquit()
	inputscr(-1, KEY_A)
end

--Installer functions
function precleanup()
	if System.doesFileExist(downloadedexe) then
		System.deleteFile(downloadedexe)
	end
	if System.doesFileExist(downloadedsmdh) then
		System.deleteFile(downloadedsmdh)
	end
	if System.doesFileExist(downloadedzip) then
		System.deleteFile(downloadedzip)
	end
	if System.doesFileExist(gamezip) then
		System.deleteFile(gamezip)
	end
end
function checkSMDH()
	if System.doesFileExist(appsmdhpath) then
		iconexist = 1
		return 1
	else
		iconexist = 0
		return 0
	end	
end
function installnew()
	headflip = 1
	head()
	debugWrite(0,60,"Downloading ZIP...", white, TOP_SCREEN)
	if updated == 0 then
		Network.downloadFile(serverjenkins,downloadedzip)
	end
	debugWrite(0,80,"Cleaning old files...", red, TOP_SCREEN)
	if updated == 0 then
		System.deleteFile(appsmdhpath)
		System.deleteFile(appexepath)
		System.deleteFile(appxmlpath)
	end
	debugWrite(0,100,"Extracting to path...", white, TOP_SCREEN)
	if updated == 0 then
		System.extractZIP(downloadedzip,appinstallpath)
	end
	debugWrite(0,120,"DONE! Press A/B to exit!", green, TOP_SCREEN)
	updated = 1
end
function install() --Deprecated code, no longer used.
	headflip = 1
	head()
	if iconexist == 0 then
		debugWrite(0,60,"SMDH not found!", red, TOP_SCREEN)
		debugWrite(0,80,"Downloading SMDH...", red, TOP_SCREEN)
		if updated == 0 then
			Network.downloadFile(serversmdhpath,downloadedsmdh)
		end
		debugWrite(0,100,"Installing SMDH...", white, TOP_SCREEN)
		if updated == 0 then
			System.renameFile(downloadedsmdh,appsmdhpath)
		end
		checkedicon = 0	

	else
		debugWrite(0,60,"SMDH Icon Exists!", green, TOP_SCREEN)
		debugWrite(0,80,"Skipping SMDH download...", white, TOP_SCREEN)
		debugWrite(0,100,"Skipping SMDH installation...", white, TOP_SCREEN)
		skipped = 1
		checkedicon = 1
	end
	debugWrite(0,120,"Downloading 3DSX...", white, TOP_SCREEN)
	if updated == 0 then
		Network.downloadFile(serverexepath,downloadedexe)
	end	
	debugWrite(0,140,"Installing 3DSX...", white, TOP_SCREEN)
	if updated == 0 then
		if System.doesFileExist(appexepath) then
			System.deleteFile(appexepath)
		end	
		System.renameFile(downloadedexe,appexepath)
	end	
	debugWrite(0,160,"DONE! Press A/B to exit!", green, TOP_SCREEN)
	updated = 1
end

--UI Screens

function head() -- Head of all screens
	if headflip == 1 then
		debugWrite(0,0,selfstring, white, TOP_SCREEN)
		debugWrite(0,20,"==============================", red, TOP_SCREEN)	
	end
	Screen.debugPrint(0,0,selfstring, white, TOP_SCREEN)
	Screen.debugPrint(0,20,"==============================", red, TOP_SCREEN)	
end

function errorscreen() --scr == 0
	head()
	Screen.debugPrint(0,40,"An error has ocurred.", white, TOP_SCREEN)
	Screen.debugPrint(0,60,"Please refer to the documentation.", white, TOP_SCREEN)
	Screen.debugPrint(0,80,"Error code: "..consoleerror, red, TOP_SCREEN)
	Screen.debugPrint(0,100,"Press A/B to quit.", white, TOP_SCREEN)
	checkquit()
	endquit()
end

function lowhead()
	Screen.debugPrint(0,0,selfstring, white, BOTTOM_SCREEN)
end

function bottomscreen(no) -- if no = 1, the original, regular screen will show. If not, an error-screen will come up.
	lowhead()
	if no == 1 then	
		Screen.debugPrint(0,20,"Latest Stable 3DSX: Build "..serverjenkinsbuildstable, green, BOTTOM_SCREEN)
		Screen.debugPrint(0,40,"Latest 3DSX: Build "..serverjenkinsbuild, green, BOTTOM_SCREEN)		
		Screen.debugPrint(0,60,"Special Thanks: Rinnegatamante", white, BOTTOM_SCREEN)
	else
		Screen.debugPrint(0,20,"Internet connection failed.", red, BOTTOM_SCREEN)
	end
	
end

function firstscreen() -- scr == 1
	head()
	Screen.debugPrint(0,40,"Welcome to EasyRPG 3DS Updater: RE!", white, TOP_SCREEN)
	Screen.debugPrint(0,100,"Please select an option:", white, TOP_SCREEN)
	Screen.debugPrint(0,120,"A) Update to latest stable build", white, TOP_SCREEN)
	Screen.debugPrint(0,140,"Y) Update to latest build", white, TOP_SCREEN)
	Screen.debugPrint(0,160,"X) Open the RPG Maker Game Store", white, TOP_SCREEN)
	Screen.debugPrint(0,180,"B) Quit to HBL", white, TOP_SCREEN)
	inputscr(2, KEY_A)
	inputscr(4, KEY_Y)
	inputscr(5, KEY_X)
	if debugmode == 1 then
		inputscr(-2, KEY_L)
	end
	checkquit()
end

function installer() --scr == 2 / scr == 4
	head()
	debugWrite(0,40,"Started Installation...", white, TOP_SCREEN)
	installnew()
	checkquit()
	checkrestart()
end

function store() --scr == 5
	head()
	if 1 == 1 then
		if storechoice == 1 then
			Screen.debugPrint(0,40,".flow",green,TOP_SCREEN)
			remotezipgame = flowZIP
		else
			Screen.debugPrint(0,40,".flow",white,TOP_SCREEN)
		end
		if storechoice == 2 then
			Screen.debugPrint(0,60,"Ib",green,TOP_SCREEN)
			remotezipgame = IbZIP
		else
			Screen.debugPrint(0,60,"Ib",white,TOP_SCREEN)
		end	
		if storechoice == 3 then
			Screen.debugPrint(0,80,"Yume Nikki",green,TOP_SCREEN)
			remotezipgame = YumeNikkiZIP
		else
			Screen.debugPrint(0,80,"Yume Nikki",white,TOP_SCREEN)
		end
		if storechoice == 4 then
			Screen.debugPrint(0,100,"TestGame-2000",green,TOP_SCREEN)
			remotezipgame = TestGameZIP
		else
			Screen.debugPrint(0,100,"TestGame-2000",white,TOP_SCREEN)
		end	
	end	
	storedpad()
	inputscr(6,KEY_A)
end

function storeinstaller()
	head()	
	debugWrite(0,40,"Starting installation...", white, TOP_SCREEN)
	installgame()
	checkquit()
	checkrestart()
end

function installgame()
	headflip = 1
	head()
	debugWrite(0,60,"Downloading ZIP...", white, TOP_SCREEN)
	if updated == 0 then
		Network.downloadFile(remotezipgame,gamezip)
	end
	debugWrite(0,80,"Extracting to path...", white, TOP_SCREEN)
	if updated == 0 then
		System.extractZIP(gamezip,appinstallpath)
		System.deleteFile(gamezip)
	end
	debugWrite(0,100,"DONE! Press B to exit!", green, TOP_SCREEN)
	updated = 1	

end
--Store-related functions
function storedpad()
	if Controls.check(pad,KEY_DUP) and not Controls.check(oldpad,KEY_DUP) then
		storechoice = storechoice - 1
		if storechoice == 0 then
			storechoice = lastchoice
		end
	elseif Controls.check(pad,KEY_DDOWN) and not Controls.check(oldpad,KEY_DDOWN) then 
		storechoice = storechoice + 1
		if storechoice == lastchoice + 1 then
			storechoice = 1
		end
	end 
end

--Prints text

function debugWrite(x,y,text,color,display)
	if updated == 1 or downloadcompleted == 1 then
		Screen.debugPrint(x,y,text,color,display)
	else
		i = 0
	
		while i < 2 do
			Screen.refresh()
			Screen.debugPrint(x,y,text,color,display)
			Screen.waitVblankStart()
			Screen.flip()
			i = i + 1
		
		end
	end
end
--Main loop

runoncevars()
iswifion()
servergetVars()
precleanup()
checkSMDH()

while true do
	clear()
	pad = Controls.read()
	bottomscreen(iswifion())
	if scr == 6 then
		storeinstaller()
	end
	if scr == 2 then
		serverjenkins = serverjenkinsstable
		installer()
	end	
	if scr == 4 then
		serverjenkins = serverjenkinslast
		installer()
	end
	if scr == 0 then
		errorscreen()
	end
	if scr == 1 then
		firstscreen()
	end
	if scr == 5 then
		store()
	end

	if scr == -2 then
		error("Debug Break")
	end
	if scr == -3 then
		error("Program ended")
	end

	iswifion()
	flip()
end