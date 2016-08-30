#!/bin/bash

set -e

location="westus"
rgname="kuberg"
lbname="kubelb"
fename="kubfe"
ipname="lbip"
bepoolname="kubbepool"
rulename="kublbrule"
probename="probe80"
vmssname="myvmss"
vmssrg="myvmssrg"



azure network lb create $rgname $lbname $location
azure network lb frontend-ip create $rgname $lbname $fenam -i $ipname
azure network public-ip create -g $rgname -n $ipname -l $location -d $lbname -a static -i 4
azure network lb address-pool create $rgname $lbname $bepoolname

azure network lb rule create -g $rgname -l $lbname -n $rulename -p tcp -f 80 -b 80 -t $fename -o $bepoolname
azure network lb probe create -g $rgname -l $lbname -n $probename -p "tcp" -o 80 -i 15 -c 4

# get the config file 
azure vmss show -g $rgname  -n $vmssname --json > $vmssname.json

#edit the json file with something like
#azure vmss config load-balancer-backend-address-pools set --parameter-file vmss.json ---ip-configurations-index 0 ....

#TODO: add the load balancer to the json
#azure vmss create --parameter-file vmss.json -g $vmssrg -n $vmssname

