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
        
        if ($id -eq 55) {
            $title = ""
        }
        
        $rawContent = ""
        if ($html -match '(?is)<a name="PageMain0"></a>(.*?)(<a name="more"></a>|<hr>|</div>\s*<!-- page footer -->)') {
            $rawContent = $matches[0]
            # Replace image URLs
            $rawContent = $rawContent -replace 'http://g-craft\.net/media/niwa_navi/([^"]+)', 'images/details/$1'
            # Remove popup links
            $rawContent = $rawContent -replace '(?is)<a href="[^"]*\?imagepopup=[^"]*"[^>]*>(.*?)</a>', '$1'
            
            # Remove the footer banner block usually starting with PageMain0 at the end (the inquiry banner)
            $rawContent = $rawContent -replace '(?is)<a name="PageMain0"></a><span id="PageLayoutViewList_PageMain_0_03ブログ.*?</span></center></span>', ''
            $rawContent = $rawContent -replace '(?is)<div style="padding: 50px 25px 30px 25px;.*?</div>', ''
            $rawContent = $rawContent -replace '(?is)G-craft（山田造園）.*?こちらのお問合せページが便利です。.*?(<br clear="all" />|<br />|</span>)*', ''
            $rawContent = $rawContent -replace '(?is)<hr size="1" style="background-color:white; border:none; border-bottom:1px dotted #555555;" />', ''
            
            # Additional cleanup of old spans that contain nothing but empty text or just tracking codes
            $rawContent = $rawContent -replace '(?is)〒849-0901<br />.*?<br />', ''
            # Remove empty <a name="PageMainX"></a> tags
            $rawContent = $rawContent -replace '<a name="PageMain\d+"></a>', ''
        }
        
        $results[$id.ToString()] = @{
            title = $title
            rawHtml = $rawContent
        }
    } catch {
        Write-Host "Error processing ID $id"
    }
}

$json = ConvertTo-Json $results -Depth 5 -Compress
# Make the JSON readable and add var prefix
$json = "const detailData = " + ($json | ConvertFrom-Json | ConvertTo-Json -Depth 5) + ";"

Set-Content -Path "data.js" -Value $json -Encoding UTF8
Write-Host "Done! Saved to data.js"
