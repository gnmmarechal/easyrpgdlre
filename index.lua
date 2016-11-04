--EasyRPG Updater: RE Client Script (CORE)
--Author: gnmmarechal
--Runs on Lua Player Plus 3DS

-- This script fetches the latest updater script and runs it. If the server-side script has a higher rel number, the CIA will also be updated.
clientrel = 1
bootstrapver = "1.0.3"

if not Network.isWifiEnabled() then --Checks for Wi-Fi
	error("Failed to connect to the network.")
end

-- Set server script URL
stableserverscripturl = "http://gs2012.xyz/3ds/easyrpgdlre/index-server.lua"
nightlyserverscripturl = "http://gs2012.xyz/3ds/easyrpgdlre/cure-nightly.lua"

--Set server CIA type (BGM/NOBGM)
if System.doesFileExist("romfs:/bgm.wav") then
	CIAupdatetype = "BGM"
else
	CIAupdatetype = "NOBGM"
end

-- Create directories
System.createDirectory("/easyrpgdlre")
System.createDirectory("/easyrpgdlre/settings")
System.createDirectory("/easyrpgdlre/resources")


-- Check if user is in devmode or no (to either use index-server.lua or cure-nightly.lua)
if System.doesFileExist("/easyrpgdlre/settings/devmode") then
	serverscripturl = nightlyserverscripturl
	devmode = 1
else
	serverscripturl = stableserverscripturl
	devmode = 0
end
-- Download server script
if System.doesFileExist("/easyrpgdlre/cure.lua") then
	System.deleteFile("/easyrpgdlre/cure.lua")
end
Network.downloadFile(serverscripturl, "/easyrpgdlre/cure.lua")

-- Run server script
if System.doesFileExist("/easyrpgdlre/cure.lua") then
	dofile("/easyrpgdlre/cure.lua")
else
	error("Script is missing. Halting.")
end
System.exit()
