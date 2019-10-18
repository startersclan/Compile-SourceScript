# - Initial setup: Fill in the GUID value. Generate one by running the command 'New-GUID'. Then fill in all relevant details.
# - Ensure all relevant details are updated prior to publishing each version of the module.
# - To simulate generation of the manifest based on this definition, run the included development entrypoint script Invoke-PSModulePublisher.ps1.
# - To publish the module, tag the associated commit and push the tag.

@{
    RootModule = 'Compile-SourceScript.psm1'
    # ModuleVersion = ''                            # Value will be set for each publication based on the tag ref. Defaults to '0.0.0' in development environments and regular CI builds
    GUID = 'b3189849-465b-472a-a85f-f04d8b27dfa0'
    Author = 'Starters Clan'
    CompanyName = 'Starters Clan'
    Copyright = '(c) 2019 Starters Clan'
    Description = 'A wrapper for compiling SourceMod (.sp) and AMX Mod X (.sma) plugin source files for Source / GoldSource games.'
    PowerShellVersion = '4.0'
    # PowerShellHostName = ''
    # PowerShellHostVersion = ''
    # DotNetFrameworkVersion = ''
    # CLRVersion = ''
    # ProcessorArchitecture = ''
    # RequiredModules = @()
    # RequiredAssemblies = @()
    # ScriptsToProcess = @()
    # TypesToProcess = @()
    # FormatsToProcess = @()
    # NestedModules = @()
    FunctionsToExport = @(
        'Compile-SourceScript'
    )
    CmdletsToExport = @()
    VariablesToExport = @()
    AliasesToExport = @()
    # DscResourcesToExport = @()
    # ModuleList = @()
    # FileList = @()
    PrivateData = @{
        # PSData = @{           # Properties within PSData will be correctly added to the manifest via Update-ModuleManifest without the PSData key. Leave the key commented out.
            Tags = @(
                'sourcemod'
                'amxmodx'
                'sourcepawn'
                'plugins'
                'srcds'
                'hlds'
                'source'
                'goldsource'
                'valve'
                'gameserver'
                'compile'
                'wrapper'
            )
            LicenseUri = 'https://raw.githubusercontent.com/startersclan/Compile-SourceScript/master/LICENSE'
            ProjectUri = 'https://github.com/startersclan/Compile-SourceScript'
            # IconUri = ''
            # ReleaseNotes = ''
            # Prerelease = ''
            # RequireLicenseAcceptance = $false
            # ExternalModuleDependencies = @()
        # }
        # HelpInfoURI = ''
        # DefaultCommandPrefix = ''
    }
}
