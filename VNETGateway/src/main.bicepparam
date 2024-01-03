using './main.bicep'

param VPNPSK = ''
param FQDN = 'www.ncsdfw.com'
param remoteBGPIP = '192.168.1.1'
param remoteName = 'HomeRouter'

param remoteASN = '64512'
param gwASN = '65512'
