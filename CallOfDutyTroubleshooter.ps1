# troubleshooter.ps1
# This PowerShell script acts as a Call of Duty Troubleshooter Helper.
# It supports commands for listing games, listing issues, troubleshooting steps, and applying crash fixes.
# The crash fix commands include a TEMP folder cleanup with errors suppressed.

$gamesData = @{
    "Cold War" = @{
        "crashes" = @(
            "Ensure your graphics drivers are up-to-date.",
            "Verify the game files using your game launcher.",
            "Run the game as an administrator."
        )
        "crash_commands" = @(
            'Write-Host "Closing Cold War processes..."',
            'Stop-Process -Name "ColdWarGame" -ErrorAction SilentlyContinue',
            'Write-Host "Clearing temporary files..."',
            'Remove-Item "$env:TEMP\*.*" -Force -Recurse -ErrorAction SilentlyContinue'
        )
        "lag" = @(
            "Check your network connection and try a wired connection if possible.",
            "Lower in-game graphics settings.",
            "Close background applications that may consume bandwidth."
        )
    }
    "BO6" = @{
        "connection" = @(
            "Restart your router and modem.",
            "Check if there are known server outages.",
            "Ensure your firewall or antivirus is not blocking the game."
        )
        "performance" = @(
            "Update your GPU drivers.",
            "Adjust in-game settings to lower quality.",
            "Disable any unnecessary background applications."
        )
        "crashes" = @(
            "Update your drivers.",
            "Verify the integrity of your game files.",
            "Install any pending system updates."
        )
        "crash_commands" = @(
            'Write-Host "Closing BO6 processes..."',
            'Stop-Process -Name "BO6Game" -ErrorAction SilentlyContinue',
            'Write-Host "Clearing temporary files..."',
            'Remove-Item "$env:TEMP\*.*" -Force -Recurse -ErrorAction SilentlyContinue'
        )
    }
}

function Show-Help {
    Write-Host "Available Commands:"
    Write-Host "  help"
    Write-Host "    - Display this help message."
    Write-Host "  list games"
    Write-Host "    - List all supported Call of Duty games."
    Write-Host "  list issues [game]"
    Write-Host "    - List common issues for a specific game."
    Write-Host "      Example: list issues 'Cold War'"
    Write-Host "  troubleshoot [game] [issue]"
    Write-Host "    - Get troubleshooting steps for a specific issue."
    Write-Host "      Example: troubleshoot BO6 connection"
    Write-Host "  fix crashes [game]"
    Write-Host "    - Run PowerShell commands to fix crashes for a game."
    Write-Host "      Example: fix crashes 'Cold War'"
    Write-Host "  exit"
    Write-Host "    - Exit the troubleshooter."
}

function List-Games {
    Write-Host "Supported Games:"
    foreach ($game in $gamesData.Keys) {
        Write-Host " - $game"
    }
}

function List-Issues($game) {
    if ($gamesData.ContainsKey($game)) {
        Write-Host "Common issues for $game:"
        # Exclude the 'crash_commands' key from the list.
        $issues = $gamesData[$game].Keys | Where-Object { $_ -ne "crash_commands" }
        foreach ($issue in $issues) {
            Write-Host " - $issue"
        }
    }
    else {
        Write-Host "Game '$game' not found. Use 'list games' to see supported titles."
    }
}

function Troubleshoot($game, $issue) {
    if ($gamesData.ContainsKey($game)) {
        # Match the issue in a case-insensitive way (excluding 'crash_commands').
        $issueKey = $gamesData[$game].Keys | Where-Object { $_.ToLower() -eq $issue.ToLower() -and $_ -ne "crash_commands" }
        if ($issueKey) {
            Write-Host "Troubleshooting steps for $game - $issueKey:"
            foreach ($step in $gamesData[$game][$issueKey]) {
                Write-Host " * $step"
            }
        }
        else {
            Write-Host "Issue '$issue' not found for $game."
            Write-Host "Available issues:"
            $gamesData[$game].Keys | Where-Object { $_ -ne "crash_commands" } | ForEach-Object {
                Write-Host " - $_"
            }
        }
    }
    else {
        Write-Host "Game '$game' not recognized. Use 'list games' to see supported titles."
    }
}

function Fix-Crashes($game) {
    Write-Host "Attempting to fix crashes for $game..."
    if ($gamesData.ContainsKey($game) -and $gamesData[$game].ContainsKey("crash_commands")) {
        $commands = $gamesData[$game]["crash_commands"]
    }
    else {
        # Fallback generic commands if no game-specific commands exist.
        $commands = @(
            'Write-Host "Closing game processes..."',
            'Stop-Process -Name "GameProcess" -ErrorAction SilentlyContinue',
            'Write-Host "Clearing temporary files..."',
            'Remove-Item "$env:TEMP\*.*" -Force -Recurse -ErrorAction SilentlyContinue'
        )
    }
    foreach ($command in $commands) {
        Write-Host "Running: $command"
        Invoke-Expression $command
    }
    Write-Host "Crash fix operations completed."
}

function Main {
    Write-Host "==============================================="
    Write-Host "Call of Duty Troubleshooter Helper"
    Write-Host "Type 'help' for a list of commands."
    Write-Host "==============================================="
    
    while ($true) {
        $input = Read-Host ">>"
        if ([string]::IsNullOrWhiteSpace($input)) { continue }
        $tokens = $input -split "\s+"
        $cmd = $tokens[0].ToLower()
        
        switch ($cmd) {
            "exit" {
                break
            }
            "help" {
                Show-Help
            }
            "list" {
                if ($tokens.Count -ge 2) {
                    if ($tokens[1].ToLower() -eq "games") {
                        List-Games
                    }
                    elseif ($tokens[1].ToLower() -eq "issues") {
                        if ($tokens.Count -ge 3) {
                            $game = $tokens[2]
                            List-Issues $game
                        }
                        else {
                            Write-Host "Usage: list issues [game]"
                        }
                    }
                    else {
                        Write-Host "Unknown list command. Use 'list games' or 'list issues [game]'."
                    }
                }
            }
            "troubleshoot" {
                if ($tokens.Count -ge 3) {
                    $game = $tokens[1]
                    # Combine all tokens after the game name to form the issue description.
                    $issue = ($tokens[2..($tokens.Count - 1)] -join " ")
                    Troubleshoot $game $issue
                }
                else {
                    Write-Host "Usage: troubleshoot [game] [issue]"
                }
            }
            "fix" {
                if ($tokens.Count -ge 3 -and $tokens[1].ToLower() -eq "crashes") {
                    $game = $tokens[2]
                    Fix-Crashes $game
                }
                else {
                    Write-Host "Usage: fix crashes [game]"
                }
            }
            default {
                Write-Host "Unknown command. Type 'help' for a list of commands."
            }
        }
    }
    Write-Host "Exiting Troubleshooter. Goodbye!"
}

# Start the helper.
Main
