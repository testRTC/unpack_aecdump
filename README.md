unpack_aecdump
=========

Dockerfile to build unpack_aecdump utility (and entire webrtc project with slight modifications)

### Building aec_dump yourself
1. Clone this repo
2. Build the Dockerfile with a tag (example: unpack_aecdump_build). This step takes a very long time and requires ~15 GB of disk space.
`docker build -t unpack_aecdump_build .`
3. Run a docker container to obtain the unpack_aecdump binary on STDOUT. `docker run --rm unpack_aecdump_build > unpack_aecdump`
4. Add executable permission to the binary and test it
```
chmod +x unpack_aecdump
./unpack_aecdump
```
