@echo off
REM Define source and destination directories
set "source=C:\Work\Addon\wow-auction-assistant\AuctionAssistant"
set "destination=C:\Program Files (x86)\World of Warcraft\_classic_era_\Interface\AddOns\AuctionAssistant"

REM Copy files excluding *.bat and .git
robocopy "%source%" "%destination%" /E /XD .git /XF *.bat /R:1 /W:1 /PURGE

REM Check for errors
if %errorlevel% geq 8 (
    echo [ERROR] File copy operation failed!
) else (
    echo [SUCCESS] Files copied successfully!
)