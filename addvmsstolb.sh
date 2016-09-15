#!/bin/bash

set -e

location="westus"
rgname="delete-vmss4"
lbname="newlb"
fename="kubfe2"
ipname="lbip2"
bepoolname="kubbepool2"
rulename="kublbrule2"
probename="probe802"
vmssname="xtophthev"    
vnetname="xtophthevvnet"

# there's got to be an easier way to grab the subscription id 
subId=$(azure account show | grep -o '  ID.*: [a-z0-9\-]*' | cut -d: -f2 | cut -d' ' -f2)
azure network lb create $rgname $lbname $location
azure network public-ip create -g $rgname -n $ipname -l $location -d $lbname -a static -i 4 

#read 
azure network lb frontend-ip create -g $rgname -l $lbname -n $fename -i $ipname -m $vnetname

#read
azure network lb address-pool create $rgname $lbname $bepoolname

azure network lb rule create -g $rgname -l $lbname -n $rulename -p tcp -f 80 -b 80 -t $fename -o $bepoolname
azure network lb probe create -g $rgname -l $lbname -n $probename -p tcp -o 80 -i 15 -c 4

# get the config file 
azure vmss show -g $rgname  -n $vmssname --json > $vmssname.json

lbbepoolid=/subscriptions/$subId/resourceGroups/$rgname/providers/Microsoft.Network/loadBalancers/$lbname/backendAddressPools/$bepoolname
azure vmss config patch --operation add --path "/virtualMachineProfile/networkProfile/networkInterfaceConfigurations/0/ipConfigurations/0/loadBalancerBackendAddressPools" --value '[{ "id" : "'$lbbepoolid'" }]' --parse  --parameter-file $vmssname.json

azure vmss create --parameter-file $vmssname.json -g $rgname -n $vmssname

# now add the virtual machines to the load balancer.
# we do this by updating / upgrading the VMs
# TODO figure out how we walk the whole VMSS in script
azure vmss update-instances -g $rgname -n $vmssname --instance-ids 0
 