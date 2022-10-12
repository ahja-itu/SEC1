# Mandatory exercise 2

I am going to solve this exerise using Elixir and its tools provided to host TCP servers and clients. 

## Protocol (work in progress)

Notes:
- We can assume that a PKI is in place, so we can get public keys for a digital signature scheme for both Alice and Bob.
  - I can just create sets of pk/vk for digital signatures for the actors such that
    they also have a private vk.  I'm going to have to compute these numbers by hand
    and pass them to the actors via ENV variables

- Arithmetic on bitstrings: using `:binary.encode_unsigned/1` and `:binary.decode_unsiged/1` we can easily move strings (binaries) between their string and numerical representation, such that we can perform arithmetic on them for the different cryptoschemes.

Protocol in progress:


## Communication protocol:




## Elixir implementation ideas


- Each client is a state machine that accepts connecitons and decide to connect to another client.
  - Steps:
    1. El Gamal signature scheme
    2. Commitment scheme with rolling dice

- Create an instructions protocol in order to identify the meaning of messages, such as in the scenario when two clients connect and they want to run an Authenticated DH scheme:
  - Alice -> Bob "AUTH $g $p $pk_a" # Begins a round of authentication
  - ...
  - Alice -> Bob: "ROLL $commitmnet_a"
  - Bob -> Alice: "ROLL $commitment_b"
  - Alice -> Bob: "REVEAL $roll"
  - Bob -> Alice: "REVEAL $roll"
  - Alice -> Bob: "RESULT IWON"
  - Bob -> Alice: "RESULT UWON" # Winning under agreement

  
