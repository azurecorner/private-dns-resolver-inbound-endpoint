## 1. Overview

Azure DNS Private Resolver allow you to create your own provate dns server and/or to query Azure DNS private zones from an on-premises environment and vice versa without deploying VM based DNS servers.

for more informations about private dns resolver you can follow the official doumentation here : <https://learn.microsoft.com/en-us/azure/dns/dns-private-resolver-overview>

In this tutorial, I will demonstrate how to create a custom DNS server using Azure DNS Private Resolver

- **inbound endpoints:** Inbound endpoints require a subnet delegated to Microsoft.Network/dnsResolvers. In a virtual network, you must configure a custom DNS server using the private IP of the inbound endpoint.

When a client within the virtual network issues a DNS query, the query is forwarded to the specified IP address, which is the private IP of the inbound endpoint of the Azure DNS Private Resolver.

DNS queries received by the inbound endpoint are processed and routed into Azure.

- **outbound endpoints:**
Outbound endpoints require a dedicated subnet delegated to Microsoft.Network/dnsResolvers within the virtual network where they are provisioned. They can be used to forward DNS queries to external DNS servers using DNS forwarding rulesets.

DNS queries sent to the outbound endpoint will exit Azure.

In this tutorial, I will configure only the inbound endpoint. The outbound endpoint will be set up in the next tutorial.

## 2. Infrastructure

To setup  DNS Private Resolver inbound endpoint, you need the following infrastructure:

- **A Hub virtual network with two subnets:**
  - Inbound subnet delegated to Microsoft.Network/dnsResolvers
  - Outbound subnet delegated to Microsoft.Network/dnsResolvers

- **A Spoke  virtual network:**
  - The spoke Vnet is used to set up our demo and should be configured to use a custom DNS server with the private IP of the Private Resolver inbound endpoint.

- **A storage account** with public network access disabled.

- **A private endpoint** within the virtual network, configured with the **file** sub-resource on the storage account.

- **A private DNS zone** (`privatelink.file.core.windows.net`) linked to the hub and spoke virtual network.

- **A Private Resolver**  is configured in the hub virtual network with an inbound endpoint.

- **An Azure virtual machine** in the spoke virtual network for the demo.
- **An Azure Bastion** in the hub virtual network, used to connect to the VM.

### 2.1 Hub Virtual Network

/*------------------------------------------ Hub Virtual Network ------------------------------------------*/

```bicep

```

### 2.2 Spoke Virtual Network

/*------------------------------------------ Spoke Virtual Network ------------------------------------------*/

```bicep

```

### 2.3 Storage Account

/*------------------------------------------ Storage Account -----------------------------------------------*/

```bicep

```

### 2.4 Storage Account  Private Endpoint

/*---------------------------------------  Storage Account  Private Endpoint ----------------------------------*/

```bicep

```

### 2.5 Private Resolver

/*------------------------------------------ Private Resolver -------------------------------------------------*/

```bicep

```

# ########################################################################################################

## notes

0. deploy the dns private resolver inside a vnet
1. Private dns resolver inbound enpoint : use a private ip adress from the vnet
2. Configure onpremise dns with a conditional forwarder  , with dns domain file.core.windows.net and the private ip of the dns resolver inbound endpoint

3. the inbound and outbound subnet should be delegated to  Microsoft.Network/dnsResolvers

4. inbound endpoint should resolve private endpoint

5. for outbound endpoint use the outbound subnet

6. create a dns rulesut and use the outbound of the dns private resolver
add a rule with domain mane of   logcorner.local.  and destination ip addrees is the private of the on premise dns server  (ex : 10.100.0.5) , port is 53
7. link the ruleset to the hub vnet
8. spokevnet should use the dnsserver : custom with ip address of private dns resolver inbound ip ( 10.200.0.70)

# #############################

```powershell
Connect-AzAccount -Tenant 'xxxx-xxxx-xxxx-xxxx' -SubscriptionId 'yyyy-yyyy-yyyy-yyyy'

Account                SubscriptionName TenantId                Environment
-------                ---------------- --------                -----------
azureuser@contoso.com  Subscription1    xxxx-xxxx-xxxx-xxxx     AzureCloud
$subscriptionId= (Get-AzContext).Subscription.id
az account set --subscription $subscriptionId
$resourceGroupName="rg-dns-private-resolver"
New-AzResourceGroup -Name $resourceGroupName -Location "westeurope"
New-AzResourceGroupDeployment -Name "FirstStage" -ResourceGroupName $resourceGroupName -TemplateFile main.bicep -Stage FirstStage
```

# ###################################################

nslookup logcornerstprivdnsrev.file.core.windows.net
Server:  UnKnown
Address:  168.63.129.16

Non-authoritative answer:
Name:    logcornerstprivdnsrev.privatelink.file.core.windows.net
Address:  10.201.0.5
Aliases:  logcornerstprivdnsrev.file.core.windows.net

Server:  UnKnown
Address:  10.200.0.70

Non-authoritative answer:
Name:    logcornerstprivdnsrev.privatelink.file.core.windows.net
Address:  10.201.0.5
Aliases:  logcornerstprivdnsrev.file.core.windows.net
