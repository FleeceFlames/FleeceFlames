$road2 = $args[0]

if ($null -eq $args[0]) { $road2 = '\Downloads\' }

$road = $env:USERPROFILE + $road2

$specialChars = "[", "]", "(", ")"

Get-ChildItem -Path $road -Filter "*`[*" | Where-Object { $_.attributes -ne "Directory" } | ForEach-Object {
    $new = $_.Name

    foreach ($char in $specialChars) {
        $new = $new.Replace($char, "")
    }

    $_ | Rename-Item -NewName $new
    Write-Output $new
}

$files = Get-ChildItem -Path $road -Force | Where-Object { $_.attributes -ne "Directory" }

Foreach ($file in $files) {
    $temproad = $env:USERPROFILE + $road2 + $file.LastWriteTime.Month + '_' + $file.LastWriteTime.Year

    if (-not (Test-Path -LiteralPath $temproad)) {
        try {
            New-Item -Path $temproad -ItemType "directory" -Force
            "Successfully created directory '$temproad'."
        } catch {
            Write-Error -Message "Unable to create directory '$temproad'. Error was: $_" -ErrorAction Stop
        }
    }

    try {
        Move-Item $file.FullName -Destination $temproad -ErrorAction Stop
    } catch {
        Write-Warning "Unable to move file $($file.Name) to $temproad"
    }
}
