// Parameters
@description('Specifies the name of an existing public DNS zone.')
param name string

@description('Specifies the name of the CNAME record to create within the DNS zone. The record will be an alias to your Front Door endpoint.')
param cnameRecordName string

@description('Specifies the time-to-live (TTL) value for the CNAME record.')
param ttl int = 3600

@description('Specifies the Front Door endpoint to which the CNAME record will point.')
param hostName string

@description('Specifies the validation state of the custom domain.')
param domainValidationState string 

@description('Specifies the validation token of the custom domain.')
param validationToken string

resource dnsZone 'Microsoft.Network/dnsZones@2023-07-01-preview' existing = {
  name: name
}

resource cnameRecord 'Microsoft.Network/dnsZones/CNAME@2023-07-01-preview' = {
  parent: dnsZone
  name: cnameRecordName
  properties: {
    TTL: ttl
    CNAMERecord: {
      cname: hostName
    }
  }
}

resource validationTxtRecord 'Microsoft.Network/dnsZones/TXT@2023-07-01-preview' = if (domainValidationState != 'Approved') {
  parent: dnsZone
  name: '_dnsauth.${cnameRecordName}'
  properties: {
    TTL: ttl
    TXTRecords: [
      {
        value: [
          validationToken
        ]
      }
    ]
  }
}

// Outputs
output dnsZoneId string = dnsZone.id
