# Petit serveur local pour ouvrir doublons-fichiers.html en http://localhost:8080
# Usage : ./serve.ps1   (depuis le dossier du projet)
#
# Choix de securite (voir CLAUDE.md) :
# - Ecoute uniquement sur localhost (jamais accessible depuis le reseau)
# - Liste blanche : un seul fichier servi (doublons-fichiers.html). Rien d'autre
#   du dossier n'est accessible (ni .git, ni ce script), ce qui supprime tout
#   risque de parcours de repertoires.
# - Methodes GET/HEAD uniquement
# - Verification de l'en-tete Host (protection contre le DNS rebinding)
# - En-tetes de securite sur chaque reponse, erreurs generiques sans detail

$ErrorActionPreference = 'Stop'

$port = 8080
$allowedFile = Join-Path $PSScriptRoot 'doublons-fichiers.html'
$allowedHosts = @("localhost:$port", "127.0.0.1:$port")

if (-not (Test-Path $allowedFile -PathType Leaf)) {
    Write-Host "doublons-fichiers.html est introuvable a cote de ce script." -ForegroundColor Red
    exit 1
}

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$port/")
$listener.Start()
Write-Host "Serveur lance : http://localhost:$port/doublons-fichiers.html" -ForegroundColor Green
Write-Host "Laissez cette fenetre ouverte. Ctrl+C pour arreter." -ForegroundColor Yellow

function Send-Status($response, [int]$code) {
    $response.StatusCode = $code
    $response.Headers.Add('X-Content-Type-Options', 'nosniff')
    $response.Close()
}

try {
    while ($listener.IsListening) {
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response
        try {
            if ($request.HttpMethod -notin @('GET', 'HEAD')) { Send-Status $response 405; continue }
            if ($allowedHosts -notcontains $request.Headers['Host']) { Send-Status $response 403; continue }

            $path = $request.Url.AbsolutePath
            if ($path -ne '/' -and $path -ne '/doublons-fichiers.html') { Send-Status $response 404; continue }

            $bytes = [System.IO.File]::ReadAllBytes($allowedFile)
            $response.ContentType = 'text/html; charset=utf-8'
            $response.Headers.Add('X-Content-Type-Options', 'nosniff')
            $response.Headers.Add('X-Frame-Options', 'DENY')
            $response.Headers.Add('Referrer-Policy', 'no-referrer')
            $response.Headers.Add('Cache-Control', 'no-store')
            $response.ContentLength64 = $bytes.Length
            if ($request.HttpMethod -eq 'GET') {
                $response.OutputStream.Write($bytes, 0, $bytes.Length)
            }
            $response.Close()
        } catch {
            # Message generique cote client, aucun detail interne expose
            try { Send-Status $response 500 } catch { }
        }
    }
} finally {
    $listener.Stop()
}
