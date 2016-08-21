<?php
echo "EasyRPG Updater Server Script"."<br>";
echo "<title>EasyRPG 3DS Build Fetcher</title>";
//Download new build
echo "\r\nDownloading latest build..."."<br>";
file_put_contents("easyrpg.zep", file_get_contents("https://ci.easyrpg.org/job/player-3ds/lastSuccessfulBuild/artifact/builds/3ds/easyrpg-player-3ds.zip"));
echo "\r\nDownloading latest stable build..."."<br>";
file_put_contents("easyrpg-stable.zep", file_get_contents("https://ci.easyrpg.org/job/player-3ds/lastStableBuild/artifact/builds/3ds/easyrpg-player-3ds.zip"));
echo "\r\nDownloading latest build (CIA)..."."<br>";
file_put_contents("easyrpg.cia", file_get_contents("https://ci.easyrpg.org/job/player-3ds/lastSuccessfulBuild/artifact/builds/3ds/easyrpg-player.cia"));
echo "\r\nDownloading latest stable build (CIA)..."."<br>";
file_put_contents("easyrpg-stable.cia", file_get_contents("https://ci.easyrpg.org/job/player-3ds/lastStableBuild/artifact/builds/3ds/easyrpg-player.cia"));


//Download file versions
echo "\r\nDownloading version information..."."<br>";
file_put_contents("ver.txt", file_get_contents("https://ci.easyrpg.org/job/player-3ds/lastSuccessfulBuild/buildNumber"));
file_put_contents("verstable.txt", file_get_contents("https://ci.easyrpg.org/job/player-3ds/lastStableBuild/buildNumber"));
echo "\r\nDone! http://gs2012.xyz"."<br>";
?>