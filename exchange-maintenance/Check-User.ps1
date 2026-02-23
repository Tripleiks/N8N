#!/usr/bin/env pwsh
Connect-ExchangeOnline -ShowBanner:$false
Write-Host "Suche nach Martina Kleinert..." -ForegroundColor Cyan

$user = Get-EXORecipient -Anr "Martina Kleinert" -ErrorAction SilentlyContinue
if ($null -eq $user) {
    Write-Host "Kein Empfänger mit dem Namen 'Martina Kleinert' gefunden." -ForegroundColor Red
}
else {
    $user | Format-List DisplayName, RecipientTypeDetails, ExchangeUserAccountControl, PrimarySmtpAddress
    
    if ($user.RecipientTypeDetails -eq 'SharedMailbox') {
        Write-Host "ACHTUNG: Dies ist bereits eine Shared Mailbox!" -ForegroundColor Yellow
    }
    elseif ($user.ExchangeUserAccountControl -notmatch 'AccountDisabled') {
        Write-Host "ACHTUNG: Das Konto in Entra ID ist aktiv (nicht deaktiviert)!" -ForegroundColor Yellow
    }
}

Disconnect-ExchangeOnline -Confirm:$false | Out-Null
