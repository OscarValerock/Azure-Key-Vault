// Use this file to write queries to test your data connector
let
    result = Azure_Key_Vault.Secret("https://bibbpbikeyvault.vault.azure.net/","Gumroad")
in
    result