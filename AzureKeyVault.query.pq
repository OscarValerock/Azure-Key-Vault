// Use this file to write queries to test your data connector
let
    result = AzureKeyVault.NavigationTable("https://bibbpbikeyvault.vault.azure.net/")
in
    result