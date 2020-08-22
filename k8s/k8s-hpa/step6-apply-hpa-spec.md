With the HPA now deployed we would expect more Pods to be started with all the CPU backpressure running in Terminal 2. You should be seeing several Pods by now.

`watch "kubectl get deployments && echo "" && kubectl get pods -l app=php-apache && echo "" && kubectl top pods -l app=php-apache && echo "" && kubectl get hpa"`{{execute T3}}

If you are not seeing more than one Pod, then something is still wrong.

This watch is listed in Terminal 3. You can leave this running while you go an try to fix the scaling problem from Terminal 1.

Once you fix the problem, the continue button will allow you to move to the final step once it sees your Pods haved scaled up.
