$ErrorActionPreference = 'Stop'
$ids = @(97, 96, 95, 94, 93, 92, 91, 90, 89, 88, 55, 45, 43, 44, 69, 70, 71)
$results = @{}

$wc = New-Object System.Net.WebClient
$enc = [System.Text.Encoding]::GetEncoding("euc-jp")

foreach ($id in $ids) {
    Write-Host "Processing ID $id..."
    $url = "http://g-craft.net/index.php?itemid=$id"
    try {
        $bytes = $wc.DownloadData($url)
        $html = $enc.GetString($bytes)
        
        $title = "Untitled"
        if ($html -match 'title="Read entry:\s*(.*?)"') {
            $title = $matches[1].Trim()
        } elseif ($html -match '<div class="bTitle">([^<]+)</div>') {
            $title = $matches[1].Trim()
        }
        
        $imgRegex = [regex]'src="(http://g-craft\.net/media/niwa_navi/[^"]+)"'
        $images = @()
        foreach ($m in $imgRegex.Matches($html)) {
            $img = $m.Groups[1].Value
            if ($img -notmatch "_popup" -and $images -notcontains $img) {
                $images += $img
            }
        }
        
        $txtRegex = [regex]'(?s)<span id="PageMain_Txt_[^>]+_ctTxt1"[^>]*>(.*?)</span>'
        $texts = @()
        foreach ($m in $txtRegex.Matches($html)) {
            $text = $m.Groups[1].Value -replace '<br />',"`n" -replace '<[^>]+>',''
            $text = $text.Trim()
            if ($text -ne "") {
                $texts += $text
            }
        }
        
        $results["$id"] = @{
            title = $title
            images = $images
            texts = $texts
        }
    } catch {
        Write-Host "Error processing $($id): $_"
    }
}

$json = ConvertTo-Json $results -Depth 10
[System.IO.File]::WriteAllText("c:\Users\user\OneDrive\デスクトップ\山田造園\scraped_data.json", $json, [System.Text.Encoding]::UTF8)
Write-Host "Done"
