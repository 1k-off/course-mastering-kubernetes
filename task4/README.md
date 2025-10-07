# Install deps
```bash
mkdir data
curl -L -o kubebuilder "https://go.kubebuilder.io/dl/latest/$(go env GOOS)/$(go env GOARCH)"
chmod +x kubebuilder && sudo mv kubebuilder /usr/local/bin/
wget https://github.com/kubernetes-sigs/controller-runtime/releases/download/v0.22.2/setup-envtest-linux-amd6
chmod +x setup-envtest-linux-amd64
./setup-envtest-linux-amd64 use
go install sigs.k8s.io/controller-tools/cmd/controller-gen@latest
```

# Lvl 1 and 2
Get code from example.

```bash
go mod init sample-controller
# refactor packages
go mod tidy
# read code and flags
controller-gen object paths="./api/..."
go test ./...
# The first problem
sudo ln -s /workspaces/course-mastering-kubernetes/kubebuilder /usr/local/kubebuilder
go test ./...
# test output
go build -o ./bin/sample-controller
```

Run the controller
```bash
k apply -f config/crd/bases/apps.newresource.com_newresources.yaml
k get crd
KUBERNETES_SERVICE_HOST=192.168.0.200 KUBERNETES_SERVICE_PORT=6433 ./bin/sample-controller
```

In another console:
```bash
curl http://127.0.0.1:8080/metrics > data/metrics.txt
# The second problem, which leads us to lvl3
```

# Lvl 3
```bash
KUBERNETES_SERVICE_HOST=192.168.0.200 KUBERNETES_SERVICE_PORT=6433 ./bin/sample-controller -leader-elect=true
# The third problem
# update code, rebuild
go build -o ./bin/sample-controller
KUBERNETES_SERVICE_HOST=192.168.0.200 KUBERNETES_SERVICE_PORT=6433 ./bin/sample-controller -leader-elect=true
# same problem, need to add RBAC
controller-gen rbac:roleName=newresource-manager paths=./... output:rbac:artifacts:config=config/rbac
k apply -f config/rbac/role.yaml
k auth can-i list newresources.apps.newresource.com --as=system:serviceaccount:default:newresource-controller
KUBERNETES_SERVICE_HOST=192.168.0.200 KUBERNETES_SERVICE_PORT=6433 ./bin/sample-controller -leader-elect=true

cat << EOF > newresource.yaml
apiVersion: apps.newresource.com/v1alpha1
kind: NewResource
metadata:
  name: test-resource
  namespace: default
spec:
  foo: "bar"
EOF
k apply -f newresource.yaml
k get newresources
# see successfull output
```


# Problems description

## The first problem
```
?       sample-controller       [no test files]
?       sample-controller/api/v1alpha1  [no test files]
?       sample-controller/controllers   [no test files]
2025-10-07T19:34:08Z    DEBUG   controller-runtime.test-env     starting control plane
2025-10-07T19:34:08Z    ERROR   controller-runtime.test-env     unable to start the controlplane        {"tries": 0, "error": "fork/exec /usr/local/kubebuilder/bin/etcd: no such file or directory"}
sigs.k8s.io/controller-runtime/pkg/envtest.(*Environment).startControlPlane
        /go/pkg/mod/sigs.k8s.io/controller-runtime@v0.22.2/pkg/envtest/server.go:366
sigs.k8s.io/controller-runtime/pkg/envtest.(*Environment).Start
        /go/pkg/mod/sigs.k8s.io/controller-runtime@v0.22.2/pkg/envtest/server.go:279
sample-controller/test.setupMainTestEnv.func1
        /workspaces/course-mastering-kubernetes/task4/test/test_utils.go:71
2025-10-07T19:34:08Z    ERROR   controller-runtime.test-env     unable to start the controlplane        {"tries": 1, "error": "fork/exec /usr/local/kubebuilder/bin/etcd: no such file or directory"}
sigs.k8s.io/controller-runtime/pkg/envtest.(*Environment).startControlPlane
        /go/pkg/mod/sigs.k8s.io/controller-runtime@v0.22.2/pkg/envtest/server.go:366
sigs.k8s.io/controller-runtime/pkg/envtest.(*Environment).Start
        /go/pkg/mod/sigs.k8s.io/controller-runtime@v0.22.2/pkg/envtest/server.go:279
sample-controller/test.setupMainTestEnv.func1
        /workspaces/course-mastering-kubernetes/task4/test/test_utils.go:71
2025-10-07T19:34:08Z    ERROR   controller-runtime.test-env     unable to start the controlplane        {"tries": 2, "error": "fork/exec /usr/local/kubebuilder/bin/etcd: no such file or directory"}
sigs.k8s.io/controller-runtime/pkg/envtest.(*Environment).startControlPlane
        /go/pkg/mod/sigs.k8s.io/controller-runtime@v0.22.2/pkg/envtest/server.go:366
sigs.k8s.io/controller-runtime/pkg/envtest.(*Environment).Start
        /go/pkg/mod/sigs.k8s.io/controller-runtime@v0.22.2/pkg/envtest/server.go:279
sample-controller/test.setupMainTestEnv.func1
        /workspaces/course-mastering-kubernetes/task4/test/test_utils.go:71
2025-10-07T19:34:08Z    ERROR   controller-runtime.test-env     unable to start the controlplane        {"tries": 3, "error": "fork/exec /usr/local/kubebuilder/bin/etcd: no such file or directory"}
sigs.k8s.io/controller-runtime/pkg/envtest.(*Environment).startControlPlane
        /go/pkg/mod/sigs.k8s.io/controller-runtime@v0.22.2/pkg/envtest/server.go:366
sigs.k8s.io/controller-runtime/pkg/envtest.(*Environment).Start
        /go/pkg/mod/sigs.k8s.io/controller-runtime@v0.22.2/pkg/envtest/server.go:279
sample-controller/test.setupMainTestEnv.func1
        /workspaces/course-mastering-kubernetes/task4/test/test_utils.go:71
2025-10-07T19:34:08Z    ERROR   controller-runtime.test-env     unable to start the controlplane        {"tries": 4, "error": "fork/exec /usr/local/kubebuilder/bin/etcd: no such file or directory"}
sigs.k8s.io/controller-runtime/pkg/envtest.(*Environment).startControlPlane
        /go/pkg/mod/sigs.k8s.io/controller-runtime@v0.22.2/pkg/envtest/server.go:366
sigs.k8s.io/controller-runtime/pkg/envtest.(*Environment).Start
        /go/pkg/mod/sigs.k8s.io/controller-runtime@v0.22.2/pkg/envtest/server.go:279
sample-controller/test.setupMainTestEnv.func1
        /workspaces/course-mastering-kubernetes/task4/test/test_utils.go:71
--- FAIL: TestMainController (0.00s)
    test_utils.go:78: 
                Error Trace:    /workspaces/course-mastering-kubernetes/task4/test/test_utils.go:78
                                                        /workspaces/course-mastering-kubernetes/task4/test/main_test.go:18
                Error:          Received unexpected error:
                                unable to start control plane itself: failed to start the controlplane. retried 5 times: fork/exec /usr/local/kubebuilder/bin/etcd: no such file or directory
                Test:           TestMainController
                Messages:       Timeout waiting for test environment to start
FAIL
FAIL    sample-controller/test  0.020s
FAIL
```

Solution: create symlink for kubebuilder to the path test wants

## Test output
```
?       sample-controller       [no test files]
?       sample-controller/api/v1alpha1  [no test files]
?       sample-controller/controllers   [no test files]
ok      sample-controller/test  9.698s
```

## The second problem
After 1 minute controller crashes with the next log:
```
2025-10-07T19:43:30Z    INFO    controller-runtime.metrics      Starting metrics server
2025-10-07T19:43:30Z    INFO    Starting EventSource    {"controller": "newresource", "controllerGroup": "apps.newresource.com", "controllerKind": "NewResource", "source": "kind source: *v1alpha1.NewResource"}
2025-10-07T19:43:30Z    INFO    controller-runtime.metrics      Serving metrics server  {"bindAddress": ":8080", "secure": false}
2025-10-07T19:44:30Z    ERROR   controller-runtime.source.Kind  failed to get informer from cache       {"error": "failed to get server groups: the server was unable to return a response in the time allotted, but may still be processing the request"}
sigs.k8s.io/controller-runtime/pkg/internal/source.(*Kind[...]).Start.func1.1
        /go/pkg/mod/sigs.k8s.io/controller-runtime@v0.22.2/pkg/internal/source/kind.go:80
k8s.io/apimachinery/pkg/util/wait.loopConditionUntilContext.func1
        /go/pkg/mod/k8s.io/apimachinery@v0.34.1/pkg/util/wait/loop.go:53
k8s.io/apimachinery/pkg/util/wait.loopConditionUntilContext
        /go/pkg/mod/k8s.io/apimachinery@v0.34.1/pkg/util/wait/loop.go:54
k8s.io/apimachinery/pkg/util/wait.PollUntilContextCancel
        /go/pkg/mod/k8s.io/apimachinery@v0.34.1/pkg/util/wait/poll.go:33
sigs.k8s.io/controller-runtime/pkg/internal/source.(*Kind[...]).Start.func1
        /go/pkg/mod/sigs.k8s.io/controller-runtime@v0.22.2/pkg/internal/source/kind.go:68
2025-10-07T19:45:30Z    ERROR   Could not wait for Cache to sync        {"controller": "newresource", "controllerGroup": "apps.newresource.com", "controllerKind": "NewResource", "source": "kind source: *v1alpha1.NewResource", "error": "failed to wait for newresource caches to sync kind source: *v1alpha1.NewResource: timed out waiting for cache to be synced for Kind *v1alpha1.NewResource"}
sigs.k8s.io/controller-runtime/pkg/internal/controller.(*Controller[...]).startEventSourcesAndQueueLocked.func1.2.1
        /go/pkg/mod/sigs.k8s.io/controller-runtime@v0.22.2/pkg/internal/controller/controller.go:366
2025-10-07T19:45:30Z    INFO    Stopping and waiting for non leader election runnables
2025-10-07T19:45:30Z    INFO    Stopping and waiting for leader election runnables
2025-10-07T19:45:30Z    INFO    Stopping and waiting for caches
2025-10-07T19:45:30Z    INFO    Stopping and waiting for warmup runnables
2025-10-07T19:45:30Z    ERROR   controller-runtime.source.Kind  failed to get informer from cache       {"error": "failed to get server groups: the server was unable to return a response in the time allotted, but may still be processing the request"}
sigs.k8s.io/controller-runtime/pkg/internal/source.(*Kind[...]).Start.func1.1
        /go/pkg/mod/sigs.k8s.io/controller-runtime@v0.22.2/pkg/internal/source/kind.go:80
k8s.io/apimachinery/pkg/util/wait.loopConditionUntilContext.func2
        /go/pkg/mod/k8s.io/apimachinery@v0.34.1/pkg/util/wait/loop.go:87
k8s.io/apimachinery/pkg/util/wait.loopConditionUntilContext
        /go/pkg/mod/k8s.io/apimachinery@v0.34.1/pkg/util/wait/loop.go:88
k8s.io/apimachinery/pkg/util/wait.PollUntilContextCancel
        /go/pkg/mod/k8s.io/apimachinery@v0.34.1/pkg/util/wait/poll.go:33
sigs.k8s.io/controller-runtime/pkg/internal/source.(*Kind[...]).Start.func1
        /go/pkg/mod/sigs.k8s.io/controller-runtime@v0.22.2/pkg/internal/source/kind.go:68
2025-10-07T19:45:30Z    INFO    Stopping and waiting for webhooks
2025-10-07T19:45:30Z    INFO    Stopping and waiting for HTTP servers
2025-10-07T19:45:30Z    INFO    controller-runtime.metrics      Shutting down metrics server with timeout of 1 minute
2025-10-07T19:45:30Z    INFO    Wait completed, proceeding to shutdown the manager
panic: failed to wait for newresource caches to sync kind source: *v1alpha1.NewResource: timed out waiting for cache to be synced for Kind *v1alpha1.NewResource

goroutine 1 [running]:
main.main()
        /workspaces/course-mastering-kubernetes/task4/main.go:51 +0x319
```

## The third problem

```
panic: unable to find leader election namespace: not running in-cluster, please specify LeaderElectionNamespace

goroutine 1 [running]:
main.main()
        /workspaces/course-mastering-kubernetes/task4/main.go:41 +0x331
```

Need to update code. 
```go
	mgr, err := manager.New(config.GetConfigOrDie(), manager.Options{
		Scheme:           scheme,
		Metrics:          server.Options{BindAddress: metricsAddr},
		LeaderElection:   enableLeaderElection,
		LeaderElectionID: "newresource-controller",
        LeaderElectionNamespace: "default",
	})
```

## Adding RBAC
Add go compiler info to `controllers/resource_controller.go`:
```
// +kubebuilder:rbac:groups=apps.newresource.com,resources=newresources,verbs=get;list;watch;create;update;patch;delete
// +kubebuilder:rbac:groups=apps.newresource.com,resources=newresources/status,verbs=get;update;patch
// +kubebuilder:rbac:groups="",resources=events,verbs=create;patch
// +kubebuilder:rbac:groups=coordination.k8s.io,resources=leases,verbs=get;list;watch;create;update;patch
```

## Successfull outpout

```
2025-10-07T20:28:34Z    INFO    controller-runtime.metrics      Starting metrics server
I1007 20:28:34.174026   64438 leaderelection.go:257] attempting to acquire leader lease default/newresource-controller...
2025-10-07T20:28:34Z    INFO    controller-runtime.metrics      Serving metrics server  {"bindAddress": ":8080", "secure": false}
I1007 20:28:34.360606   64438 leaderelection.go:271] successfully acquired lease default/newresource-controller
2025-10-07T20:28:34Z    DEBUG   events  codespaces-52263d_99c5f30a-55dd-4d52-b22a-d18b33548571 became leader    {"type": "Normal", "object": {"kind":"Lease","namespace":"default","name":"newresource-controller","uid":"48d6c005-eae1-46bf-bc27-d0215b6d583a","apiVersion":"coordination.k8s.io/v1","resourceVersion":"217"}, "reason": "LeaderElection"}
2025-10-07T20:28:34Z    INFO    Starting EventSource    {"controller": "newresource", "controllerGroup": "apps.newresource.com", "controllerKind": "NewResource", "source": "kind source: *v1alpha1.NewResource"}
2025-10-07T20:28:34Z    INFO    Starting Controller     {"controller": "newresource", "controllerGroup": "apps.newresource.com", "controllerKind": "NewResource"}
2025-10-07T20:28:34Z    INFO    Starting workers        {"controller": "newresource", "controllerGroup": "apps.newresource.com", "controllerKind": "NewResource", "worker count": 1}
2025-10-07T20:35:08Z    INFO    Reconciling     {"controller": "newresource", "controllerGroup": "apps.newresource.com", "controllerKind": "NewResource", "NewResource": {"name":"test-resource","namespace":"default"}, "namespace": "default", "name": "test-resource", "reconcileID": "35a1f43a-3b8b-4308-a5b0-c048c8a809c8", "name": "test-resource"}
2025-10-07T20:35:08Z    INFO    Reconciling     {"controller": "newresource", "controllerGroup": "apps.newresource.com", "controllerKind": "NewResource", "NewResource": {"name":"test-resource","namespace":"default"}, "namespace": "default", "name": "test-resource", "reconcileID": "f7816473-e0b2-4a1f-ae53-8e8dc3108d02", "name": "test-resource"}
```

