# Petit serveur local pour ouvrir doublons-fichiers.html en http://localhost:8080
# Usage : ./serve.ps1   (depuis le dossier du projet)

$root = $PSScriptRoot
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:8080/")
$listener.Start()
Write-Host "Serveur lancé : http://localhost:8080/doublons-fichiers.html" -ForegroundColor Green
Write-Host "Laissez cette fenêtre ouverte. Ctrl+C pour arrêter." -ForegroundColor Yellow

try {
    while ($listener.IsListening) {
        $context = $listener.GetContext()
        $path = $context.Request.Url.LocalPath.TrimStart('/')
        if ($path -eq '') { $path = 'doublons-fichiers.html' }

        # Ne servir que des fichiers situés dans le dossier du projet
        $filePath = [System.IO.Path]::GetFullPath((Join-Path $root $path))
        if ($filePath.StartsWith($root) -and (Test-Path $filePath -PathType Leaf)) {
            $bytes = [System.IO.File]::ReadAllBytes($filePath)
            $context.Response.ContentType = "text/html; charset=utf-8"
            $context.Response.OutputStream.Write($bytes, 0, $bytes.Length)
        } else {
            $context.Response.StatusCode = 404
        }
        $context.Response.OutputStream.Close()
    }
} finally {
    $listener.Stop()
}
