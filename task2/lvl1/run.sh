#!/usr/bin/env bash
DEFAULT_KUBEBUILDER_BIN_PATH="/workspaces/course-mastering-kubernetes/kubebuilder/bin"
HOST_IP=$(hostname -I | awk '{print $1}')

is_running() {
    pgrep -f "$1" >/dev/null
}

check_path_exists() {
    local path="$1"
    if [ -d "$path" ]; then
        return 0
    else
        echo "Path does not exist: $path"
        return 1
    fi
}

if [ -z "$KUBEBUILDER_BIN_PATH" ]; then
    KUBEBUILDER_BIN_PATH="$DEFAULT_KUBEBUILDER_BIN_PATH"
fi

if ! is_running "containerd"; then
    echo "Starting containerd..."
    export PATH=$PATH:/opt/cni/bin:$KUBEBUILDER_BIN_PATH
    sudo PATH=$PATH:/opt/cni/bin:/usr/sbin /opt/cni/bin/containerd -c /etc/containerd/config.toml &
fi

if [ ! -f "/var/lib/kubelet/pki/kubelet.crt" ] || [ ! -f "/var/lib/kubelet/pki/kubelet.key" ]; then
    echo "Generating self-signed kubelet serving certificate..."
    sudo openssl req -x509 -newkey rsa:2048 -nodes \
        -keyout /var/lib/kubelet/pki/kubelet.key \
        -out /var/lib/kubelet/pki/kubelet.crt \
        -days 365 \
        -subj "/CN=$(hostname)"
    sudo chmod 600 /var/lib/kubelet/pki/kubelet.key
    sudo chmod 644 /var/lib/kubelet/pki/kubelet.crt
fi
sudo cp ./config/kubelet.yaml /var/lib/kubelet/config.yaml

if ! is_running "kubelet"; then
    echo "Starting kubelet..."
    sudo PATH=$PATH:/opt/cni/bin:/usr/sbin $KUBEBUILDER_BIN_PATH/kubelet \
        --kubeconfig=/var/lib/kubelet/kubeconfig \
        --config=/var/lib/kubelet/config.yaml \
        --root-dir=/var/lib/kubelet \
        --cert-dir=/var/lib/kubelet/pki \
        --hostname-override=$(hostname) \
        --node-ip=$HOST_IP \
        --v=1 &
fi

mkdir -p /etc/kubernetes/manifests
cp /var/lib/kubelet/kubeconfig /etc/kubernetes/kubeconfig.yaml
cp /var/lib/kubelet/ca.crt /etc/kubernetes/ca.crt

cp ./kube-system/etcd.yaml /etc/kubernetes/manifests/
cp ./kube-system/kube-apiserver.yaml /etc/kubernetes/manifests/
cp ./kube-system/kube-scheduler.yaml /etc/kubernetes/manifests/
cp ./kube-system/kube-controller-manager.yaml /etc/kubernetes/manifests/