# Mandatory exercise 2

I am going to solve this exercise using Elixir and its tools provided to host TCP servers and clients. 

TODO:

- [ ] Add mutual TLS
  - [ ] [Generate certs](https://kevinhoffman.medium.com/mutual-tls-over-grpc-with-elixir-a071d514deb3) for both Alice and Bob:
  - [ ] Configure [HTTPoison to work with mutual TLS](https://elixirforum.com/t/2-way-ssl-mutual-tls-with-httpoison-and-hackney/31206/6)
  - [ ] Probably need to also look at [this](https://michaelviveros.medium.com/mutual-tls-in-elixir-part-1-httpoison-b8a727669d88) article for mutual TLS
- [ ] Add more logging to server module
- [ ] General code clean up:
  - [ ] Make sure that all commitment business goes through the `Commitment` module
  - [ ] Organize Client code in separate functions for cleaner code
  - [ ] Organize Server code in separate functions for cleaner code (?)
- [ ] Capture logs for the written report
- [ ] Write the report


## Resources

Generate certs with this template (maybe need to create own CA for this)

```sh
openssl req \
  -x509 \
  -newkey rsa:4096 \
  -keyout "$name.key.pem" \
  -out "$name.cert.pem" \
  -sha256 \
  -days 365 \
  -nodes \
  -subj "/CN=$name"
```
