// This file contains your Data Connector logic
section Azure_Key_Vault;
apiVersion = "7.4";


[DataSource.Kind="Azure_Key_Vault", Publish="Azure_Key_Vault.Publish"]
shared Azure_Key_Vault.NavigationTable = (vaultBaseUrl as text) as table =>
let
    objects = #table(
        {"Name", "Key", "Data", "ItemKind", "ItemName", "IsLeaf"},
        {
            {
                "Secret",
                "Secret",
                (secretName as text) => Azure_Key_Vault.Secret(vaultBaseUrl, secretName), 
                "Function",
                "Secret",
                true
            }
        }
    ),
    NavTable = Table.ToNavigationTable(objects, {"Key"}, "Name", "Data", "ItemKind", "ItemName", "IsLeaf")
in
    NavTable;


shared Azure_Key_Vault.Secret = (vaultBaseUrl as text, secretName as text) =>
    let
        Source = Json.Document(
            Web.Contents(
                vaultBaseUrl,
                [
                    RelativePath = "secrets/" & secretName & "/?api-version=" & apiVersion
                ]
            ),
                65001)[value]
    in
        Source;
        
Azure_Key_Vault.TestConnection = (vaultBaseUrl as text) =>
    let
        Source = Json.Document(
            Web.Contents(
                vaultBaseUrl,
                [
                    RelativePath = "?api-version=" & apiVersion
                ]
            ),
                65001)[value]
    in
        Source;

// Data Source Kind description
Azure_Key_Vault = [
    TestConnection = (dataSourcePath) => { "Azure_Key_Vault.TestConnection" },
    Authentication = [
        Aad = [
            AuthorizationUri = "https://login.microsoftonline.com/common/oauth2/authorize",
            Resource = "https://vault.azure.net"
        ]
    ],
    Label = Extension.LoadString("DataSourceLabel")
];

// Data Source UI publishing description
Azure_Key_Vault.Publish = [
    Beta = true,
    Category = "Other",
    ButtonText = { Extension.LoadString("ButtonTitle"), Extension.LoadString("ButtonHelp") },
    LearnMoreUrl = "https://powerbi.microsoft.com/",
    SourceImage = Azure_Key_Vault.Icons,
    SourceTypeImage = Azure_Key_Vault.Icons
];

Azure_Key_Vault.Icons = [
    Icon16 = { Extension.Contents("Azure_Key_Vault16.png"), Extension.Contents("Azure_Key_Vault20.png"), Extension.Contents("Azure_Key_Vault24.png"), Extension.Contents("Azure_Key_Vault32.png") },
    Icon32 = { Extension.Contents("Azure_Key_Vault32.png"), Extension.Contents("Azure_Key_Vault40.png"), Extension.Contents("Azure_Key_Vault48.png"), Extension.Contents("Azure_Key_Vault64.png") }
];

//Navigation table helper function
Table.ToNavigationTable = (
    table as table,
    keyColumns as list,
    nameColumn as text,
    dataColumn as text,
    itemKindColumn as text,
    itemNameColumn as text,
    isLeafColumn as text
) as table =>
    let
        tableType = Value.Type(table),
        newTableType = Type.AddTableKey(tableType, keyColumns, true) meta 
        [
            NavigationTable.NameColumn = nameColumn, 
            NavigationTable.DataColumn = dataColumn,
            NavigationTable.ItemKindColumn = itemKindColumn, 
            NavigationTable.IsLeafColumn = isLeafColumn
        ],
        navigationTable = Value.ReplaceType(table, newTableType)
    in
        navigationTable;
