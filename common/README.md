# How to create and upload hermetic xz and tar tool archives

Extraction of `tar.xz` files can take significant amount of time when `xz`
doesn't have multithreading feature. Bazel uses Java implementation of `tar`
that doesn't support multithreading. To speed up extraction, we use hermetic
`tar` and `xz` archives with multithreading support.

At the moment, this extraction of `.tar` and `tar.xz` files with hermetic tools
is supported only for Linux platform.

## XZ archive

The archive should be made on Linux machine with GLIBC 2.31 or earlier version
(for example, Ubuntu 20.04 LTS).

1. Download latest xz sources package from https://github.com/tukaani-project/xz/releases.

   ```
   wget https://github.com/tukaani-project/xz/releases/download/v<version>/xz-<version>.tar.xz
   ```

2. Extract the package to a local directory.

   ```
   tar -xvf xz-<version>.tar.xz -C <custom xz location>
   ```

3. Execute the following commands:

   ```
   cd <custom xz location>/xz-<version>
   sudo apt install autopoint po4a
   ./autogen.sh
   ./configure --prefix=$(pwd)/installation
   make
   make install
   ```

4. Update RUNPATH of `xz` file.
   ```
   sudo apt install patchelf
   patchelf --set-rpath '$ORIGIN/../lib' xz
   ```

5. Delete extra files that are not needed.
   - delete the folder `$(pwd)/installation/share`
   - delete all the files except `xz` in `$(pwd)/installation/bin`.

6. Rename the folder:
   - for linux x86_64 platform:
     ```
     mv $(pwd)/installation $(pwd)/xz_x86_64_<xz_version>-<archive_version>
     ```

   - for linux aarch64 platform:
     ```
     mv $(pwd)/installation $(pwd)/xz_aarch64_<xz_version>-<archive_version>
     ```
   
   Note that archive version should be different than the one existing in the
   `gs://ml-sysroot-testing` bucket.

7. Create a tar archive.
   - for linux x86_64 platform:
     ```
     tar cf - xz_x86_64_<xz_version>-<archive_version> | xz -T8 -c > xz_x86_64_<xz_version>-<archive_version>.tar.xz
     ```

   - for linux aarch64 platform:
     ```
     tar cf - xz_aarch64_<xz_version>-<archive_version> | xz -T8 -c > xz_aarch64_<xz_version>-<archive_version>.tar.xz
     ```

8. Upload the archive to the GCS bucket.
   ```
   gsutil cp <tar.xz file> gs://ml-sysroot-testing
   ```

9. Update the `xz_x86_64` or `xz_aarch64` data in
   `cc/deps/cc_toolchain_deps.bzl` file.

## TAR archive

The archive should be made on Linux machine with GLIBC 2.31 or earlier version
(for example, Ubuntu 20.04 LTS).

1. Download latest tar sources package from https://www.gnu.org/software/tar.

   ```
   wget https://ftp.gnu.org/gnu/tar/tar-<version>.tar.xz
   ```

2. Extract the package to a local directory.

   ```
   tar -xvf tar-<version>.tar.xz -C <custom tar location>
   ```

3. Execute the following commands:

   ```
   cd <custom tar location>/tar-<version>
   ./configure --prefix=$(pwd)/installation
   make
   make install
   ```

4. Delete extra files that are not needed.
   - delete the folder `$(pwd)/installation/share`
   - delete all the files except `tar` in `$(pwd)/installation/bin`.

5. Rename the folder:
   - for linux x86_64 platform:
     ```
     mv $(pwd)/installation $(pwd)/tar_x86_64_<tar_version>-<archive_version>
     ```

   - for linux aarch64 platform:
     ```
     mv $(pwd)/installation $(pwd)/tar_aarch64_<tar_version>-<archive_version>
     ```
   Note that archive version should be different than the one existing in the
   `gs://ml-sysroot-testing` bucket.

6. Create a tar archive.
   - for linux x86_64 platform:
     ```
     tar cf - tar_x86_64_<tar_version>-<archive_version> | xz -T8 -c > tar_x86_64_<tar_version>-<archive_version>.tar.xz
     ```

   - for linux aarch64 platform:
     ```
     tar cf - tar_aarch64_<tar_version>-<archive_version> | xz -T8 -c > tar_aarch64_<tar_version>-<archive_version>.tar.xz
     ```

7. Upload the archive to the GCS bucket.
   ```
   gsutil cp <tar.xz file> gs://ml-sysroot-testing
   ```

8. Update the `tar_x86_64` or `tar_aarch64` data in
   `cc/deps/cc_toolchain_deps.bzl` file.


