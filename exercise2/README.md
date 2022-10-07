# Mandatory exercise 2

I am going to solve this exerise using Elixir and its tools provided to host TCP servers and clients. 

## Protocol (work in progress)

Notes:
- We can assume that a PKI is in place, so we can get public keys for a digital signature scheme for both Alice and Bob.
  - For the PKI I can leverage some built in tools for workign with digital signatures which is talked about [here](https://elixirforum.com/t/right-way-to-use-crypto-verify/19014/3)


Protocol in progress:

- With the public keys for digital signatures, run an Authenticated Diffie-Hellman scheme to obtain shared secrets
  - From the exericse, the network is insecure, which means we might want to encrypt the messages that we send across the network as with having them authenticated. This is perhaps(?) important when we need Alice and Bob needs to open commitments so adversaries doesn't corrupt messages and cause turmoil when determinig whos won.

 



## Elixir implementation ideas


- Each client is a state machine that accepts connecitons and decide to connect to another client.
  - Steps:
    1. Authenticate
    2. 

- Create an instructions protocol in order to identify the meaning of messages, such as in the scenario when two clients connect and they want to run an Authenticated DH scheme:
  - Alice -> Bob "AUTH $g $p $pk_a" # Begins a round of authentication
  - ...
  - Alice -> Bob: "ROLL $commitmnet_a"
  - Bob -> Alice: "ROLL $commitment_b"
  - Alice -> Bob: "REVEAL $roll"
  - Bob -> Alice: "REVEAL $roll"
  - Alice -> Bob: "RESULT IWON"
  - Bob -> Alice: "RESULT UWON" # Winning under agreement

  
