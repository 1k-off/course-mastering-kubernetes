Find apiserver pod and PID
```bash
k get pods -n kube-system
POD_NAME="kube-apiserver-codespaces-52263d" # update to your pod name
k get pod -n kube-system $POD_NAME -o wide
NODE_NAME="codespaces-52263d"
kubectl debug node/$NODE_NAME -it --image=verizondigital/kubectl-flame:v0.2.4-perf --profile=sysadmin -- sh
chroot /host
ps -ef | grep kube-apiserver
PID=93371
find / -name perf -print
/app/perf record -F 99 -g -p $PID -o /tmp/out
/app/perf script -i /tmp/out | /app/FlameGraph/stackcollapse-perf.pl | /app/FlameGraph/flamegraph.pl > /tmp/flame.svg
cp /tmp/flame.svg /host/workspaces/course-mastering-kubernetes/task2/lvl2/
exit
k get pods
POD_NAME="node-debugger-codespaces-52263d-sc82d"
k delete pod $POD_NAME
```