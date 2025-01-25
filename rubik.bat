@ECHO OFF
@REM Must add all these exports, windows shits itself otherwise...
java													^
	--add-exports java.base/java.lang=ALL-UNNAMED		^
	--add-exports java.desktop/sun.awt=ALL-UNNAMED		^
	--add-exports java.desktop/sun.java2d=ALL-UNNAMED	^
	-jar target/rubik-1.0-SNAPSHOT.jar %*
