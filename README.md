
# Brief

Generate static tor for the following platforms:
  * linux x86_64
  * linux arm_32
  * Windows x86_32
  * Windows x86_64

# To build the project

```bash
docker build -t torstaticbuilder .
```

# Retreive the project

```bash
id=$(docker create torstaticbuilder:latest)
docker cp $id:/build/build build
docker rm -v $id
```

# delete the container:

```bash
docker image rm torstaticbuilder:latest
```
