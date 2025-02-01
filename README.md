# izuma-cloud-client-builder

### Build container:

Go to project root and run:

```
./build.sh
```

### Usage:

### Build with pre-generated update_default_resources.c

```
docker run --rm -v ./local-creds:/auth -v /tmp:/out -it izuma-cloud-client-builder 
```

Pass in your `mbed_cloud_dev_credentials.c` and `update_default_resources.c` by placing them in a local folder passed to the container as `/auth`

Pass in a volume for `/out` to place finished binaries.


### Build with generated update_default_resources.c


```
docker run --rm -e IZUMA_ACCESS_KEY=ak_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx -v ./local-creds:/auth -v /tmp:/out -it izuma-cloud-client-builder 
```

Pass in your [access key](https://developer.izumanetworks.com/docs/device-management/current/user-account/application-access-keys.html) in the env var `IZUMA_ACCESS_KEY`

Pass in your `mbed_cloud_dev_credentials.c` by placing them in a local folder passed to the container as `/auth`

Pass in a volume for `/out` to place finished binaries.

### Running a build

In the container, from `/builder` run:

```
./use-builder.sh windriver-aarch64
```

you will have a prompt like:

```
[windriver-aarch64]root@1aa3bd3ecb59:
```

Do

```
[windriver-aarch64]root@1aa3bd3ecb59: bash build-mbed-cloud-client.sh
```

This will attempt to build the mbed-cloud-client example

#### Output

Output is placed in /out in the container.

```
[windriver-aarch64]root@207e5d4217c7:/builder/windriver-aarch64# ls -al /out
total 6772
drwxrwxr-x 3 1001 1001    4096 Aug 21 16:57 .
drwxr-xr-x 1 root root    4096 Aug 21 16:56 ..
drwxr-xr-x 2 root root    4096 Aug 21 16:57 manifest-dev-tool-aarch64
-rwxr-xr-x 1 root root 6921488 Aug 21 16:57 mbedCloudClientExample-aarch64.elf
[windriver-aarch64]root@b8a9f08d456f:/builder/windriver-aarch64# file /out/mbedCloudClientExample-aarch64.elf
/out/mbedCloudClientExample-aarch64.elf: ELF 64-bit LSB executable, ARM aarch64, version 1 (SYSV), dynamically linked, interpreter /lib/ld-linux-aarch64.so.1, for GNU/Linux 3.7.0, with debug_info, not stripped
```

As long as you used a volume mount you can grab it outside the container. 

The `manifest-dev-tool` folder is the folder output by the `manifest-tool` during the build process.

#### Options

Use `-e IZUMA_USE_CORES=n` to use `n` number of cores for cmake, which can speed up build dramatically. Default is `8`
