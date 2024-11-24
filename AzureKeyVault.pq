// This file contains your Data Connector logic
[Version = "0.1.0"]
section AzureKeyVault;
apiVersion = "7.4";

[DataSource.Kind="AzureKeyVault", Publish="AzureKeyVault.Publish"]
shared AzureKeyVault.NavigationTable = (vaultBaseUrl as text) as table =>
let
    objects = #table(
        {"Name", "Key", "Data", "ItemKind", "ItemName", "IsLeaf"},
        {
            {
                "Secret",
                "Secret",
                (secretName as text) => AzureKeyVault.Secret(vaultBaseUrl, secretName), 
                "Function",
                "Secret",
                true
            }
        }
    ),
    NavTable = Table.ToNavigationTable(objects, {"Key"}, "Name", "Data", "ItemKind", "ItemName", "IsLeaf")
in
    NavTable;


AzureKeyVault.Secret = Value.ReplaceType(secret,secretype);



    secret = (vaultBaseUrl as text, secretName as text) =>
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


shared AzureKeyVault.GetSecret = Value.ReplaceType(getSecret,secretype);

    getSecret =  (vaultBaseUrl as text, secretName as text) =>
    let
        Source= AzureKeyVault.NavigationTable(vaultBaseUrl) {[Key="Secret"]}[Data](secretName)
    in
        Source;

secretype = type function (
    vaultBaseUrl as (type text meta [
        Documentation.FieldCaption = " vaultBaseUrl field caption ",
        Documentation.FieldDescription = " vaultBaseUrl field description ",
        Documentation.SampleValues = {"https://myvault.vault.azure.net/"},
        Formatting.IsMultiLine = false,
        Formatting.IsCode = false
    ]),
    secretName as (type number meta [
        Documentation.FieldCaption = " secretName field caption ",
        Documentation.FieldDescription = " secretName field description ",
        Documentation.SampleValues = {"mysecret"},
        Formatting.IsMultiLine = false,
        Formatting.IsCode = false
    ])
) as list ;
 
AzureKeyVault.TestConnection = (vaultBaseUrl as text) =>
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
AzureKeyVault = [
    TestConnection = (dataSourcePath) => { "AzureKeyVault.TestConnection" },
    Authentication = [
        Aad = [
            AuthorizationUri = "https://login.microsoftonline.com/common/oauth2/authorize",
            Resource = "https://vault.azure.net"
        ]
    ],
    Label = Extension.LoadString("DataSourceLabel")
];

// Data Source UI publishing description
AzureKeyVault.Publish = [
    Beta = true,
    Category = "Other",
    ButtonText = { Extension.LoadString("ButtonTitle"), Extension.LoadString("ButtonHelp") },
    LearnMoreUrl = "https://powerbi.microsoft.com/",
    SourceImage = AzureKeyVault.Icons,
    SourceTypeImage = AzureKeyVault.Icons
];

AzureKeyVault.Icons = [
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
