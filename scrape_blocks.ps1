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
        
        # Match both image spans and text spans in order
        $regex = [regex]'(?is)<span id="PageMain_(Img|Txt)_[^>]+>(.*?)</span>'
        $blocks = @()
        
        foreach ($m in $regex.Matches($html)) {
            $type = $m.Groups[1].Value
            $contentHtml = $m.Groups[2].Value
            
            if ($type -eq 'Img') {
                if ($contentHtml -match 'src="(http://g-craft\.net/media/niwa_navi/([^"]+))"') {
                    $imgUrl = $matches[1]
                    $filename = $matches[2]
                    if ($imgUrl -notmatch "_popup") {
                        $localPath = "images/details/$filename"
                        $blocks += @{ type = "image"; content = $localPath }
                    }
                }
            } elseif ($type -eq 'Txt') {
                $text = $contentHtml -replace '<br\s*/?>', "`n" -replace '<[^>]+>', ''
                $text = $text.Trim()
                if ($text -ne "") {
                    $blocks += @{ type = "text"; content = $text }
                }
            }
        }
        
        $results["$id"] = @{
            title = $title
            blocks = $blocks
        }
    } catch {
        Write-Host "Error processing $($id): $_"
    }
}

$json = ConvertTo-Json $results -Depth 10
[System.IO.File]::WriteAllText("c:\Users\user\OneDrive\デスクトップ\山田造園\data.js", "const detailData = $json;", [System.Text.Encoding]::UTF8)
Write-Host "Done"
