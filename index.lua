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

--App details
versionmajor = 1
versionminor = 0
versionrev = 0
versionstage = "RC" --Alpha, Beta, Nightly, RC (Release Candidate), Stable
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
downloadedexe = selfpath..appinstallname..".3dsx"
downloadedsmdh = selfpath..appinstallname..".smdh"

--Server strings (some vars are declared by functions after reading the strings from the server)
serverpath = "http://gs2012.pe.hu/3ds/"..selfname.."/"

servergetexepath = serverpath.."3dsx.txt"
servergetsmdhpath = serverpath.."smdh.txt"
servergetcommit = serverpath..appinstallname..".txt"

--serverexepath = serverpath..appinstallname..".3dsx"
--serversmdhpath = serverpath..appinstallname..".smdh"


-- Colours
white = Color.new(255,255,255)
green = Color.new(0,240,32)
red = Color.new(255,0,0)

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
		servercommit = Network.requestString(servergetcommit)
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
function install()
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
		Screen.debugPrint(0,20,"Latest 3DSX: "..servercommit, green, BOTTOM_SCREEN)
		Screen.debugPrint(0,40,"Author: gnmmarechal", white, BOTTOM_SCREEN)
		Screen.debugPrint(0,60,"Special Thanks: Rinnegatamante", white, BOTTOM_SCREEN)
	else
		Screen.debugPrint(0,20,"Internet connection failed.", red, BOTTOM_SCREEN)
	end
	
end

function firstscreen() -- scr == 1
	head()
	Screen.debugPrint(0,40,"Press A to update EasyRPG or B to quit", white, TOP_SCREEN)
	nextscr(2)
	checkquit()
end

function installer() --scr == 2
	head()
	debugWrite(0,40,"Started Installation...", white, TOP_SCREEN)
	install()
	checkquit()
	endquit()
end

--Prints text

function debugWrite(x,y,text,color,display)
	if updated == 1 then
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
	if scr == 2 then
		installer()
	end	
	if scr == 0 then
		errorscreen()
	end
	if scr == 1 then
		firstscreen()
		--installer()
	end

	iswifion()
	flip()
end