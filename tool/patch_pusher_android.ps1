# Applies Reverb host/port support to pusher_channels_flutter Android plugin.
# Run after `flutter pub get` if realtime connection fails on Android.

$ErrorActionPreference = 'Stop'

$pluginFile = Join-Path $env:LOCALAPPDATA "Pub\Cache\hosted\pub.dev\pusher_channels_flutter-2.6.0\android\src\main\kotlin\com\pusher\channels_flutter\PusherChannelsFlutterPlugin.kt"

if (-not (Test-Path $pluginFile)) {
  Write-Error "Plugin file not found: $pluginFile"
}

$content = Get-Content $pluginFile -Raw

$needle = @'
            if (call.argument<String>("authorizer") != null) options.channelAuthorizer = this
            if (call.argument<String>("proxy") != null) {
'@

$replacement = @'
            if (call.argument<String>("authorizer") != null) options.channelAuthorizer = this
            if (call.argument<String>("host") != null) options.setHost(call.argument("host"))
            if (call.argument<Int>("wsPort") != null) options.setWsPort(call.argument("wsPort")!!)
            if (call.argument<Int>("wssPort") != null) options.setWssPort(call.argument("wssPort")!!)
            if (call.argument<String>("proxy") != null) {
'@

if ($content -notmatch [regex]::Escape('options.setHost')) {
  $content = $content.Replace($needle, $replacement)
  Set-Content -Path $pluginFile -Value $content -NoNewline
  Write-Host "Patched pusher_channels_flutter Android plugin for Reverb host/port."
} else {
  Write-Host "Patch already applied."
}
