The puropose of this tool is to have the ability to run a single comand inputing a rholang code and outputing flamegraph during block creation with this code inside.
Please find below the prerequisites, some tips that might make workflow easier, and how to use the script `getflamegraph.sh` itself.

## 1. Install tmux and [async-profiler](https://github.com/jvm-profiling-tools/async-profiler)
### Linux
```sh
apt-get install tmux
wget https://github.com/jvm-profiling-tools/async-profiler/releases/download/v1.6/async-profiler-1.6-linux-x64.tar.gz \
-O /tmp/async-profiler-1.6-linux-x64.tar.gz && \ 
mkdir -p ~/async-profiler && \
tar -xvzf /tmp/async-profiler-1.6-linux-x64.tar.gz -C ~/async-profiler
```
### MAC 
```sh
brew install tmux
wget https://github.com/jvm-profiling-tools/async-profiler/releases/download/v1.6/async-profiler-1.6-macos-x64.tar.gz \
-O /tmp/async-profiler-1.6-macos-x64.tar.gz && \
mkdir -p ~/async-profiler && \
tar -xvzf /tmp/async-profiler-1.6-macos-x64.tar.gz -C ~/async-profiler
```

## 2. Run rnode once in a stanalone mode 
So it creates bonds file. We'll use one of the keys from this file to start a validator. Any version will do.

```sh
rnode run -s
```
Wait till records `Created validator...` or `Parsing validator...` are shown in logs and kill RNode.

## 3. Download wallets file
Put this file into genesis folder.

```sh
wget https://raw.githubusercontent.com/nzpr/rnode-flamegraph/master/wallets.txt
```

In this file the first line is a wallet that we know private key for. So we can use it to pay for deploys.

```
Private key: f8d756125e35da03cc66d5b8411881e72ea57f65bd67800f650336d1a9f827fb
Public key:  dba8d5ee12813f61c3fe875172915da39027d164f840e4fc83bf38312f371b4c07812549d9a5ad06ccd8aa40e03cecaf794357848298933db11445ee64c39b5f
ETH Address: 0x4f8237a7172bb5d57d18f25ebcf9e43f5b61e2bf
REV address: 1111Ysns49wrejhzKeUP25JXFaMhYXVWMz4DALNEh3vCUJBYpHLDz
```

## 4. Evaluate 

### Make binary with all the changes.
Inside your rchain project folder
```sh
sbt clean rholang/bnfc:clean rholang/bnfc:generate compile node/universal:stage
```
this will generate RNode binary in ./node/target/universal/stage/bin/rnode

### Download and run getflamegraph.sh
```
wget https://raw.githubusercontent.com/nzpr/rnode-flamegraph/master/getflamegraph.sh
```

The script inputs .rho contract and outputs the flamegraph of java CPU usage. 
Accepts only single contract for now.

WARNING! this script cleans state of your node in ~/.rnode.

Script runs rnode in tmux in session `rnode-benchmark`, so if you need to kill that rnode instance, 
use `tmux kill-session -t "rnode-benchmark"`. This will be called after flamegraph is created and we don't need RNode instance anymore.
Profiling starts 2 seconds after `propose` call, and lasts for 30 sec. 

```sh 
sh getflamegraph.sh <contract.rho>
```
