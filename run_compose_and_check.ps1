$docker = 'C:\Program Files\Docker\Docker\resources\bin\docker.exe'
$composeFile = 'c:\Users\rajes\Downloads\OpenWA-main\OpenWA-main\docker-compose.dev.yml'
$log = 'c:\Users\rajes\Downloads\OpenWA-main\OpenWA-main\compose_run_output.txt'
if (Test-Path $log) { Remove-Item $log -Force }
$env:Path = 'C:\Program Files\Docker\Docker\resources\bin;' + $env:Path
"PATH=$env:Path" | Out-File -FilePath $log -Append
"---DOCKER VERSION---" | Out-File -FilePath $log -Append
& $docker --version 2>&1 | Out-File -FilePath $log -Append
"---COMPOSE UP---" | Out-File -FilePath $log -Append
& $docker compose -f $composeFile up -d 2>&1 | Out-File -FilePath $log -Append
"---COMPOSE PS---" | Out-File -FilePath $log -Append
& $docker compose -f $composeFile ps 2>&1 | Out-File -FilePath $log -Append
"---LOGS openwa (200)---" | Out-File -FilePath $log -Append
& $docker compose -f $composeFile logs --no-color --tail 200 openwa 2>&1 | Out-File -FilePath $log -Append
"---HTTP CHECKS---" | Out-File -FilePath $log -Append
try { $r = Invoke-WebRequest -UseBasicParsing http://localhost:2785/api/health/ready -TimeoutSec 10; "health:" + $r.StatusCode | Out-File -FilePath $log -Append } catch { "health_fail:" + $_.Exception.Message | Out-File -FilePath $log -Append }
try { $r = Invoke-WebRequest -UseBasicParsing http://localhost:2785 -TimeoutSec 10; "root:" + $r.StatusCode | Out-File -FilePath $log -Append } catch { "root_fail:" + $_.Exception.Message | Out-File -FilePath $log -Append }
try { $r = Invoke-WebRequest -UseBasicParsing http://localhost:2785/api -TimeoutSec 10; "api:" + $r.StatusCode | Out-File -FilePath $log -Append } catch { "api_fail:" + $_.Exception.Message | Out-File -FilePath $log -Append }
try { $r = Invoke-WebRequest -UseBasicParsing http://localhost:2785/api/docs -TimeoutSec 10; "docs:" + $r.StatusCode | Out-File -FilePath $log -Append } catch { "docs_fail:" + $_.Exception.Message | Out-File -FilePath $log -Append }
Write-Output "WROTE_LOG:$log"