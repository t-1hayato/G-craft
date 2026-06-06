$wc = New-Object System.Net.WebClient
$enc = [System.Text.Encoding]::GetEncoding("euc-jp")
$html = $enc.GetString($wc.DownloadData("http://g-craft.net/index.php?itemid=96"))

if ($html -match '(?is)<a name="PageMain0"></a>(.*?)(<a name="more"></a>|<hr>|</div>\s*<!-- page footer -->)') {
    $rawContent = $matches[0]
    # Replace the image URLs
    $rawContent = $rawContent -replace 'http://g-craft\.net/media/niwa_navi/([^"]+)', 'images/details/$1'
    # Remove popup links
    $rawContent = $rawContent -replace '(?is)<a href="[^"]*\?imagepopup=[^"]*"[^>]*>(.*?)</a>', '$1'
    # Remove specific unneeded footers/banners
    $rawContent = $rawContent -replace '(?is)<a name="PageMain0"></a><span id="PageLayoutViewList_PageMain_0_03ブログ.*?</span></center></span>', ''
    $rawContent = $rawContent -replace '(?is)<div style="padding: 50px 25px 30px 25px;.*?</div>', ''
    
    Write-Host "Length: " $rawContent.Length
    Write-Host $rawContent.Substring($rawContent.Length - 500, 500)
} else {
    Write-Host "Not matched!"
}
