# .SYNOPSIS
#     rust development environment ocal Setup script
# .DESCRIPTION
#     A longer description of the script, its purpose, common use cases, etc.
# .NOTES
#     Information or caveats about the script e.g. 'This script is not supported in Linux'
# .LINK
#     Specify a URI to a help page, this will show when Get-Help -Online is used.
# .EXAMPLE
#     ./Setup.ps1 -Verbose
#     Explanation of the script or its result. You can include multiple examples with additional .EXAMPLE lines

$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$url = 'https://static.rust-lang.org/rustup/archive/1.25.1/i686-pc-windows-msvc/rustup-init.exe'
$url64 = 'https://static.rust-lang.org/rustup/archive/1.25.1/x86_64-pc-windows-msvc/rustup-init.exe'

class rspackage {
    [string] $name = "rustup"
    [string] $description = "rustup: the Rust toolchain installer"
    [version] $version = "1.25.1"
    [string] $authors = "Mozilla"
    [string] $projectUrl = "https://rustup.rs"
    $unzipLocation  = $toolsDir
    $fileType       = 'exe'
    $url            = $url
    $url64bit       = $url64
    $checksumType64 = 'sha256'
    $silentArgs     = '-v -y' # it seems we need '-v -y' starting with 1.9.0 to get rustup copied to the .cargo\bin folder.
    hidden [int[]] $validExitCodes = @(0, -1073741515)
    hidden [string] $licenseUrl = "https://github.com/rust-lang/rustup.rs#license"
    hidden [bool] $requireLicenseAcceptance = $true
    hidden [string] $sourceUrl = "https://github.com/rust-lang/rustup.rs"
    hidden [string] $docsUrl = "https://github.com/rust-lang/rustup.rs/blob/master/README.md"
    hidden [string] $bugTrackerUrl = "https://github.com/rust-lang/rustup.rs/issues"
    hidden [string[]] $tags = ('rustup', 'rust')
    rspackage() {}
}

# If you’re using Linux or macOS, open a terminal and enter the following command:
# $ curl --proto '=https' --tlsv1.2 https://sh.rustup.rs -sSf | sh

