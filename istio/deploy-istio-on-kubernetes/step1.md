Kubernetes is already started and running, maybe take a few minutes to get everything up and running. Let's check the health of the cluster.

## Health Check

You can get the status of the cluster with these commands: `kubectl cluster-info`{{execute}} and `kubectl get pods --all-namespaces`{{execute}}

> Until you wait, got to the IDE tab to load it, it'll take a few seconds to be ready.
> Wait until all pods appear and run and then hit <kbd>Ctrl</kbd>+<kbd>C</kbd> on the terminal to proceed.`echo "Ready to go."`{{execute interrupt}}
