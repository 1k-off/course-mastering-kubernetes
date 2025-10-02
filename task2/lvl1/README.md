If first run - do init actions with running `./init_commands.sh` from task 1

To run everuthing run `./run.sh`. There's a problem when kubelet starts earlier than containerd boots. I'm too lazy to write a waiter, so copying commands one by one.

To stop everything run `./stop.sh`.

Solution is in the `SOLUTION.md`.