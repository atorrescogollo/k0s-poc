# k0s PoC
Deploy k0s as a Service (PoC).

#### First steps
```bash
git clone git@github.com:kubernetes-sigs/kubespray.git
git clone git@github.com:movd/k0s-ansible.git
git clone git@github.com:atorrescogollo/k0s-poc.git
cd k0s-poc/
export CLUSTER_NAME=cluster01
```
## Create the infra
In order to create a production ready cluster infraestructure, we can take advantage from [kubespray terraform section](https://github.com/kubernetes-sigs/kubespray/tree/master/contrib/terraform).

### Openstack infra with kubespray
```bash
# Create custom infra definition
mkdir -p inventory/$CLUSTER_NAME/group_vars
cd inventory/$CLUSTER_NAME/
cp -vL ../../../kubespray/contrib/terraform/openstack/hosts .
cp -v ../../../kubespray/contrib/terraform/openstack/sample-inventory/cluster.tfvars .
ln -svf ../../scripts/k0sinventory.sh .

# EDIT the cluster.tfvars file as described in:
#   https://github.com/kubernetes-sigs/kubespray/blob/master/contrib/terraform/openstack/README.md
vim cluster.tfvars
```
> TIP: Check [this example](./README.d/kubespray-openstack-diff-example.md).

```bash
# Prepare OpenStack cloud config:
#   https://github.com/kubernetes-sigs/kubespray/blob/master/contrib/terraform/openstack/README.md#openstack-access-and-credentials
export OS_CLOUD=k0s

# Deploy the infra (tested with Terraform v0.13.7)
terraform init ../../../kubespray/contrib/terraform/openstack
terraform apply -var-file=cluster.tfvars ../../../kubespray/contrib/terraform/openstack
```

```bash
# Check reachability
export ANSIBLE_HOST_KEY_CHECKING=False
ansible all -i ./k0sinventory.sh -m ping
```


## Bootstrap k0s with k0s-ansible
```bash
# Bootstrap the cluster with k0s-ansible
ansible-playbook -i ./k0sinventory.sh ../../../k0s-ansible/site.yml
```
