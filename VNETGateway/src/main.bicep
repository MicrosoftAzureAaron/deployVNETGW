@description('Azure Datacenter location for the resources')
param location string = 'southcentralus'

@description('Site to Site Connection Pre Shared Key')
param VPNPSK string

@description('Site to Site Connection Remote FQDN')
param FQDN string

@description('Site to Site Connection Remote BGP IP')
param remoteBGPIP string

@description('Site to Site Connection Remote Name')
param remoteName string

@description('Gateway subnet for VNET')
param GWSub object = {
  name: 'GatewaySubnet'
  addressPrefix: '10.0.0.0/24'
}

module VPNVNET '../../modules/Microsoft.Network/VirtualNetwork.bicep' = {
  name: 'deployVNET'
  params: {
    addressPrefixes: [ '10.0.0.0/16' ]
    location: location
    name: 'VPN_Gateway_VNET'
    subnets: [ GWSub ]
  }
}

module VPNGW '../../modules/Microsoft.Network/VirtualNetworkGateway.bicep' = {
  name: 'deployVPNGW'
  params: {
    location: location
    virtualNetworkGateway_ASN: 65512
    virtualNetworkGateway_Name: 'VNETGW'
    virtualNetworkGateway_Subnet_ResourceID: VPNVNET.outputs.subnetResourceIds[0]
    virtualNetworkGateway_SKU: 'VpnGw2AZ'
  }
}

module Azure2Home '../../modules/Microsoft.Network/Connection_and_LocalNetworkGateway.bicep' = {
  name: 'deployLNGandConnection'
  params: {
    location: location
    virtualNetworkGateway_ID: VPNGW.outputs.virtualNetworkGateway_ResourceID
    vpn_Destination_ASN: 64512
    vpn_Destination_BGPIPAddress: remoteBGPIP
    vpn_Destination_Name: remoteName
    vpn_Destination_PublicIPAddress: FQDN
    vpn_SharedKey: VPNPSK
  }
}
