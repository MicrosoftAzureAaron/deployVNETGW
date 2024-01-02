@description('Azure Datacenter location for the resources')
param location string = 'southcentralus'

@description('')
param VPNPSK string

module VPNVNET '../../modules/Microsoft.Network/VirtualNetwork.bicep' = {
  name: 'deployVNET'
  params: {
    virtualNetwork_AddressPrefix: '10.0.0.0/16'
    location: location
    virtualNetwork_Name: 'VNETGatewayVNET'
  }
}

module VPNGW '../../modules/Microsoft.Network/VirtualNetworkGateway.bicep' = {
  name: 'deployVPNGW'
  params: {
    location: location
    virtualNetworkGateway_ASN: 65512
    virtualNetworkGateway_Name: 'VNETGW'
    virtualNetworkGateway_Subnet_ResourceID: VPNVNET.outputs.gateway_SubnetID
    virtualNetworkGateway_SKU: 'VpnGw2AZ'
  }
}

module Azure2Home '../../modules/Microsoft.Network/Connection_and_LocalNetworkGateway.bicep' = {
  name: 'deployLNGandConnection'
  params: {
    location: location
    virtualNetworkGateway_ID: VPNVNET.outputs.virtualNetwork_ID
    vpn_Destination_ASN: 64512
    vpn_Destination_BGPIPAddress: '192.168.1.1'
    vpn_Destination_Name: 'HomeRouter'
    vpn_Destination_PublicIPAddress: 'www.ncsdfw.com'
    vpn_SharedKey: VPNPSK
  }
}
