param(
    [string]$c,
    [string]$f,
    [string]$t,
    [string]$b,
    [string]$r
)
$envTemplate = Get-Content ".\.env-template" -Raw
$envTemplate = $envTemplate -replace "DEV_PROJECT_NAME", $c
$envTemplate = $envTemplate -replace "DEV_FIRMWARE_TARGET", $f
$envTemplate = $envTemplate -replace "DEV_COM_PORT", $b
$envTemplate = $envTemplate -replace "DEV_COM_RELAY_PORT", $r
$envTemplate | Set-Content ".\.env"
$argumentsTemplate = Get-Content ".\arguments.robot-template" -Raw
$argumentsTemplate = $argumentsTemplate -replace "DEV_PROJECT", $c
$argumentsTemplate = $argumentsTemplate -replace "DEV_FIRMWARE_TARGET", $f
$argumentsTemplate = $argumentsTemplate -replace "DEV_TEST_TYPE", $t
$argumentsTemplate | Set-Content ".\arguments.robot"
