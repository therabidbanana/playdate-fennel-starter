$compress = @{
    Path = "./source/main.lua", "./source/assets"
    CompressionLevel = "Fastest"
    DestinationPath = "./app.zip"
}
Compress-Archive @compress
