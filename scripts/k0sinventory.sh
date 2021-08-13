#!/usr/bin/env bash

TMPDIR=$(mktemp -d)
trap "rm -rf $TMPDIR" EXIT

cat << 'EOF' > $TMPDIR/kubespray_inventory_converter.jq
.
| . + { controller        : { hosts: .kube_control_plane.hosts[1:] }}
| . + { worker            : .kube_node }
| . + { initial_controller: { hosts: [.kube_control_plane.hosts[0]] }}
| .all.children |= . + ["controller","worker","initial_controller"]
EOF

ansible-inventory -i ./hosts $@ | jq -f $TMPDIR/kubespray_inventory_converter.jq
