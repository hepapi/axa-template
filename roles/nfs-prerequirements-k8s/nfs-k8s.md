#### Nfs Server için Kubernetes cluster gereklilik kurulumu
```
    cd ~/ansible-template    ## ansible server dan yapılmalıdır
    ansible-playbook playbooks/nfs-playbook-k8s.yaml
```

```
ansible-template/roles/nfs-prerequirements-k8s/vars/main.yaml

nfs-server-ip: bilgileri girilmelidir
```


- test için master node da aşağıdaki örnek pod, pvc çalıştırılabilir ve mount olduğu görülür

```
  apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: nfs-pvc
spec:
  accessModes:
    - ReadWriteMany
  storageClassName: nfs-sc
  resources:
    requests:
      storage: 1Gi

---

apiVersion: v1
kind: Pod
metadata:
  name: nfs-test-pod
spec:
  containers:
  - name: app
    image: alpine
    command: ["/bin/sh"]
    args: ["-c", "while true; do date >> /mnt/data/date.txt; sleep 5; done"]
    volumeMounts:
    - name: nfs
      mountPath: "/mnt/data"
  volumes:
  - name: nfs
    persistentVolumeClaim:
      claimName: nfs-pvc

```