# Kill all RNode instances
kill -9 `jps | grep "Main" | cut -d " " -f 1`

# Clear the state to always run node with fresh genesis
rm -Rf ~/.rnode/tmp/ && rm -Rf ~/.rnode/rspace && \
rm -Rf ~/.rnode/dagstorage && rm -Rf ~/.rnode/blockstore && \
rm -Rf ~/.rnode/last-finalized-block && rm -Rf ~/.rnode/rnode.log && \
tmux new-session -d -s "rnode-benchmark" ./node/target/docker/stage/opt/docker/bin/rnode run -s \
--synchrony-constraint-threshold 0.0 --validator-private-key $(cat ~/.rnode/genesis/*.sk | tail -1)

grep -q "Requested fork tip from peers" ~/.rnode/rnode.log 2> /dev/null; ready=$?
while [ $ready -ne 0 ]
do
  echo "$ready Waiting for RNode to start..."
  sleep 1
  grep -q "Requested fork tip from peers" ~/.rnode/rnode.log 2> /dev/null; ready=$?
done

# Deploy contract passed as arg
echo "RNode ready. Deploying..."
rnode deploy --phlo-limit 100000000000000 --phlo-price 1 \
--private-key f8d756125e35da03cc66d5b8411881e72ea57f65bd67800f650336d1a9f827fb $1 
echo "Proposing"; rnode propose &
# Sleep for 2s to make sure we're running profiler in the middle of propose, dump flamegraph 
sleep 2 
echo "Starting profiler" && ~/async-profiler/profiler.sh -d 30 $(jps | grep Main | cut -d " " -f1) -f $1.svg
echo "$1.svg is ready. Killing RNode."
# Kill RNode tmux
tmux kill-session -t "rnode-benchmark"
