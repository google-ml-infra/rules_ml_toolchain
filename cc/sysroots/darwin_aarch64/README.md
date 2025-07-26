# How to add macOS SDK?

Distributing the MacOSX.sdk directly is not recommended. 
It's part of Apple's proprietary development tools and distributing 
it could violate their licensing terms.

For testing cross-platform builds, developers may provide their own macOS development kit (SDK).

To set up the SDK for macOS:
1. Install Xcode: Download and install the latest version of Xcode from the Apple App Store.
2. Open a Terminal: Launch the Terminal application.
3. Run the following commands:

<code>cd &#96;xcrun -show-sdk-path&#96;/..</code>
<br />
<code>
    tar cf - MacOSX.sdk | xz -4e > ~/MacOSX.sdk.tar.xz
</code>
<br />

4. Copy `MacOSX.sdk.tar.xz` to the computer with current project. 
Let's imagine that you copy or download SDK to `~/Downloads` directory and the project path is 
`~/Projects/rules_ml_toolchain`. 
5. Extract MacOSX.sdk to the project directory `sysroots/darwin_aarch64` directory with help of next command:

`tar xf ~/Downloads/MacOSX.sdk.tar.xz -C ~/Projects/rules_ml_toolchain/cc/sysroots/darwin_aarch64/`

That's it, you project is ready for cross-platform builds where target is macOS ARM64.

### Troubleshooting

Create link to SDK or rename SDK directory to `MacOSX.sdk` if default directory name contains SDK version.

##### Errors
ERROR: Infinite symlink expansion, for cc/sysroots/darwin_aarch64/MacOSX.sdk/System/Library/Frameworks/Ruby.framework/Versions/2.6/Headers/ruby/ruby, skipping: Infinite symlink expansion
###### How to fix?
Just remove recursive symlink. Example: 
`rm cc/sysroots/darwin_aarch64/MacOSX.sdk/System/Library/Frameworks/Ruby.framework/Versions/2.6/Headers/ruby/ruby`
