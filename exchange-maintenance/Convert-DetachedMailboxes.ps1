#!/usr/bin/env pwsh
# Requires module: ExchangeOnlineManagement
# Install-Module ExchangeOnlineManagement -Scope CurrentUser

# -------------------------------------------------------------------
# Skript-Ziel: 
# Dieses Skript sucht nach deaktivierten Benutzer-Postfächern 
# (sogenannten "detached" Mailboxen) und bietet an, diese in 
# "Shared Mailboxes" (freigegebene Postfächer) umzuwandeln.
# Dadurch bleiben die Daten erhalten, ohne dass eine Lizenz 
# verbraucht wird.
# -------------------------------------------------------------------

# Baut die Verbindung zu den Exchange Online (Microsoft 365) Servern auf
Write-Host "Verbinde mit Exchange Online..." -ForegroundColor Cyan
Connect-ExchangeOnline -ShowBanner:$false

Write-Host "Suche nach deaktivierten Mailbox-Accounts..." -ForegroundColor Cyan

# 1. Ermittle alle deaktivierten UserMailboxen (diese stehen zur Umwandlung an)
# Hier werden alle regulären Benutzer-Postfächer von Microsoft 365 abgerufen
$userMailboxes = Get-EXOMailbox -RecipientTypeDetails UserMailbox -ResultSize Unlimited -Properties ExchangeUserAccountControl

# In dieser leeren Liste werden wir später die Postfächer speichern, die deaktiviert sind
$detachedMailboxes = @()

# Wir gehen jedes einzelne Benutzer-Postfach durch...
foreach ($mbx in $userMailboxes) {
    # ... und prüfen, ob das dazugehörige Benutzerkonto in Microsoft 365 deaktiviert ist ("AccountDisabled")
    if ($mbx.ExchangeUserAccountControl -match 'AccountDisabled') {
        # Wenn es deaktiviert ist, fügen wir es unserer Umwandlungs-Liste hinzu
        $detachedMailboxes += $mbx
    }
}

# 2. Ermittle alle Shared Mailboxen, deren verbundener Account deaktiviert ist (nur zur Info)
# Jetzt rufen wir alle Postfächer ab, die BEREITS zu Shared Mailboxen umgewandelt wurden
$sharedMailboxes = Get-EXOMailbox -RecipientTypeDetails SharedMailbox -ResultSize Unlimited -Properties ExchangeUserAccountControl

# Eine weitere Liste für Postfächer, die schon umgewandelt wurden (nur zur statistischen Info für uns)
$alreadyShared = @()

# Wieder gehen wir jedes dieser Postfächer durch...
foreach ($mbx in $sharedMailboxes) {
    # ... und prüfen ebenfalls, ob das zugrundeliegende Konto deaktiviert ist
    if ($mbx.ExchangeUserAccountControl -match 'AccountDisabled') {
        $alreadyShared += $mbx
    }
}

# Wenn bereits umgewandelte Postfächer gefunden wurden, geben wir eine kurze Information aus
if ($alreadyShared.Count -gt 0) {
    Write-Host "Zur Info: Es wurden $($alreadyShared.Count) deaktivierte Accounts gefunden, die BEREITS Shared Mailboxen sind." -ForegroundColor Green
    
    # Speicherort für unsere Info-Datei festlegen (im Home-Verzeichnis des Benutzers)
    $exportPathShared = "$($env:HOME)/Bereits_Shared_Mailboxes.csv"
    
    # Speichere eine kleine Tabelle (CSV) mit dem Namen, der E-Mail-Adresse und dem Status ab
    $alreadyShared | Select-Object DisplayName, PrimarySmtpAddress, ExchangeUserAccountControl | Export-Csv -Path $exportPathShared -NoTypeInformation -Encoding UTF8
    
    Write-Host "Die komplette Liste wurde hier gespeichert: $exportPathShared" -ForegroundColor DarkGray
    Write-Host "----------------------------------------------------`n" -ForegroundColor DarkGray
}

# Wenn unsere Liste mit den NOCH UMZUWANDELNDEN Postfächern nach der Suche immer noch leer ist...
if ($detachedMailboxes.Count -eq 0) {
    # ... geben wir eine Meldung aus, beenden die Verbindung zu Exchange und schließen das Skript (da nichts zu tun ist)
    Write-Host "Es wurden keine 'detached' (deaktivierten) User-Mailboxen gefunden, die noch umgewandelt werden müssten." -ForegroundColor Green
    Disconnect-ExchangeOnline -Confirm:$false | Out-Null
    exit
}

# Wenn wir aber Postfächer gefunden haben, listen wir sie hier zur Kontrolle in einer Tabelle auf
Write-Host "Gefundene deaktivierte User-Mailboxen, die noch UMWANDELBAR sind ($($detachedMailboxes.Count)):" -ForegroundColor Yellow
$detachedMailboxes | Select-Object DisplayName, PrimarySmtpAddress, ExchangeUserAccountControl | Format-Table

# Nun kommt die Sicherheitsabfrage: Wir fragen den Benutzer, ob er die gefundenen Postfächer WIRKLICH umwandeln möchte
$choice = Read-Host "Möchtest du diese Mailboxen in Shared Mailboxes umwandeln? (J/N)"

# Wenn der Benutzer mit 'J' oder 'j' (für Ja) antwortet...
if ($choice -match "^[Jj]") {
    # ... gehen wir jedes gefundene Postfach aus unserer Umwandlungs-Liste durch
    foreach ($mbx in $detachedMailboxes) {
        Write-Host "Wandle $($mbx.DisplayName) in Shared Mailbox um..." -ForegroundColor Cyan
        try {
            # Hier passiert die eigentliche Magie: Das Postfach bekommt direkt in der Cloud den neuen Typ "Shared" zugewiesen
            Set-Mailbox -Identity $mbx.ExternalDirectoryObjectId -Type Shared -ErrorAction Stop
            Write-Host "Erfolgreich umgewandelt: $($mbx.DisplayName)" -ForegroundColor Green
        }
        catch {
            # Falls ein Fehler auftritt (z.B. durch fehlende Rechte), wird dieser in Rot angezeigt. 
            # Das Skript stürzt aber nicht ab, sondern macht einfach beim nächsten Postfach weiter.
            Write-Host "Fehler bei der Umwandlung von $($mbx.DisplayName): $_" -ForegroundColor Red
        }
    }
}
else {
    # Wenn der Benutzer mit etwas anderem als J/j geantwortet hat (z.B. 'N' für Nein), brechen wir den Vorgang einfach ab.
    Write-Host "Vorgang abgebrochen. Es wurden keine Mailboxen umgewandelt." -ForegroundColor Yellow
}

# Ganz am Ende trennen wir ordnungsgemäß und sicherheitshalber wieder die bestehende Verbindung zu den Exchange Servern
Write-Host "Trenne Verbindung zu Exchange Online..." -ForegroundColor Cyan
Disconnect-ExchangeOnline -Confirm:$false | Out-Null
