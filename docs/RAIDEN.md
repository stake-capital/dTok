# Raiden Setup Archive

### May 13, 2019 - Notes from Raiden Nodes Bootstrap (Pre-Light Client) for dTok Livepeer Demo

- Each node requires RPC connectivity to an Ethereum node.

- Infura is [not recommend](https://raiden-network.readthedocs.io/en/stable/overview_and_guide.html?highlight=infura#using-eth-rpc-endpoint-infura) for use as an Ethereum node for Raiden. This is due to the lack of nonce support by Infura (an error will occur when attempting to start the Raiden process). We had previously encountered this issue during the [ETHCapeTown Hackathon](https://medium.com/stakecapital/ethcapetown-hackathon-winners-168520fdefec).

- A Parity light node cannot be used for connecting the Raiden nodes.

- We opted to run our Ethereum node on the Kovan testnet since mainnet Raiden does not support all ERC-20 payment channels and since Kovan is the only testnet with an active MakerDAO deployment of Dai.

- We initially ran our own full parity node with the following command (on a dedicated `t2.medium` AWS instance):  
```
/usr/bin/parity --no-ancient-blocks --cache-size 3584 --db-compaction ssd --tracing off --pruning fast --mode active --jsonrpc-apis=all --jsonrpc-hosts=all --jsonrpc-cors=all --jsonrpc-interface=all
```
- The `t2.medium` instance did not provide enough resources (continual oscillation between catching up and being synced), thus we switched to an `m5d.large` instance and were able to effectively sync the chain.

- However, due to delays in syncing the Kovan full node (more than 1 million blocks on the Kovan chain was going to take more than 12 hours and we were on a tight schedule for the demo) and due to the cost of running such a resource-intensive instance, we decided to seek an alternative node’s RPC endpoint to connect the Raiden nodes to.

- Jacob (of Raiden) was kind enough to offer his [dAppNode](https://github.com/dappnode/dappnode/) Kovan endpoint via an OpenVPN connection.

- We attempted to connect our Raiden node to the dAppNode using OpenVPN from Ubuntu (following [these steps](https://github.com/dappnode/dappnode/wiki/openvpn-client-guide#ubuntu--networkmanager), but without access to the GUI).

- Even with the help of Jacob (from Raiden) and vdo (from dAppNode) we couldn’t successfully connect to the VPN. The issue was that Ubuntu has it's own resolver (Network Manager / `nmcli`), and we couldn't open the connection (`sudo nmcli connection up DAppNode_VPN` was resulting in `Connection activation failed: Could not find source connection`). We followed [these steps](https://computingforgeeks.com/how-to-use-nmcli-to-connect-to-openvpn-server-on-linux/).

- ENS is used by dAppNode to resolve the VPN connection endpoint of the dAppNode. We were unable to connect to OpenVPN via `cmcli` on Ubuntu because the ENS name was not being effectively resolved. We were also unable to configure the Ubuntu resolver to resolve the ENS name of the dAppNode.

- A work-around is required to effectively configure the Ubuntu OS resolver to resolve ENS names, as described [here](https://unix.stackexchange.com/a/457441) (in a partially working solution) and [here](https://blog.samuel.domains/blog/tutorials/openvpn-systemd-and-pushed-dns) (in a fully working solution). 

- We eventually opted to instead use MakerDAO's public Ethereum RPC endpoint (that supports Kovan). Switching to this MakerDAO endpoint saved us computing resources (an `m5d.large` is costly to run). This MakerDAO Ethereum node also does not suffer from Infura’s nonce bug. The endpoint is here: `https://parity0.kovan.makerfoundation.com:8545/`
