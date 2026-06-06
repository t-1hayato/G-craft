$worksIds = @(97, 96, 95, 94, 93, 92, 91, 90, 89, 88, 55)
$html = Get-Content "c:\Users\user\OneDrive\デスクトップ\山田造園\works.html" -Raw -Encoding UTF8

for ($i = 0; $i -lt $worksIds.Length; $i++) {
    $id = $worksIds[$i]
    $num = $i + 1
    
    # Replace opening div
    $search = '<!-- Work ' + $num + '( \(造園\))? -->' + "`n" + '                <div class="work-card"'
    $replace = '<!-- Work ' + $num + ' -->' + "`n" + '                <a href="detail.html?id=' + $id + '&type=works" class="work-card"'
    $html = [System.Text.RegularExpressions.Regex]::Replace($html, $search, $replace)
    
    # We also need to replace the closing </div> of work-card with </a>.
    # We can match from <a href="..." class="work-card" ... to the matching </div>.
    # A simple regex for this is to replace the </div> right after </p>\s*</div>\s*</div> with </a>
    # Actually, the structure is:
    #                 <div class="work-info" style="padding: 20px;">
    #                     <h3 ...>...</h3>
    #                     <p ...>...</p>
    #                 </div>
    #             </div>  <-- We want to change this to </a>
}
# A safe way to replace the closing tag is to match the exact pattern:
$html = $html -replace '(</p>\s*</div>\s*)</div>', "`$1</a>"
Set-Content "c:\Users\user\OneDrive\デスクトップ\山田造園\works.html" $html -Encoding UTF8

$galleryIds = @(71, 70, 69, 45, 44, 43)
$htmlG = Get-Content "c:\Users\user\OneDrive\デスクトップ\山田造園\gallery.html" -Raw -Encoding UTF8

for ($i = 0; $i -lt $galleryIds.Length; $i++) {
    $id = $galleryIds[$i]
    $num = $i + 1
    
    $search = '<!-- Item ' + $num + ' -->' + "`n" + '                <div class="work-card"'
    $replace = '<!-- Item ' + $num + ' -->' + "`n" + '                <a href="detail.html?id=' + $id + '&type=gallery" class="work-card"'
    $htmlG = [System.Text.RegularExpressions.Regex]::Replace($htmlG, $search, $replace)
}
$htmlG = $htmlG -replace '(</p>\s*</div>\s*)</div>', "`$1</a>"
Set-Content "c:\Users\user\OneDrive\デスクトップ\山田造園\gallery.html" $htmlG -Encoding UTF8
