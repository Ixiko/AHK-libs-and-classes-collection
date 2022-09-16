GetGitHubReleaseAssetURL(repo, ext:='.zip', release:='latest') {
    req := ComObject('Msxml2.XMLHTTP')
    req.open('GET', 'https://api.github.com/repos/' repo '/releases/' release, false)
    req.send()
    if req.status != 200
        throw Error(req.status ' - ' req.statusText, -1)
    
    res := JSON_parse(req.responseText)
    try
        assets := res.assets
    catch PropertyError
        throw Error(res.message, -1)
    
    loop assets.length {
        asset := assets.%A_Index-1%
        if SubStr(asset.name, -StrLen(ext)) = ext {
            return asset.browser_download_url
        }
    }
    
    JSON_parse(str) {
        htmlfile := ComObject('htmlfile')
        htmlfile.write('<meta http-equiv="X-UA-Compatible" content="IE=edge">')
        return htmlfile.parentWindow.JSON.parse(str)
    }
}