param (
    [string]$templatePath,
    [string]$outputPath,
    [string[]]$oldValues,
    [string[]]$newValues
)

$templateContent = Get-Content $templatePath

for ($i = 0; $i -lt $oldValues.Length; $i++) {
    $templateContent = $templateContent -replace $oldValues[$i], $newValues[$i]
}

Set-Content $outputPath $templateContent
