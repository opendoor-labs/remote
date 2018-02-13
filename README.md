Remote presenters
=================
Allow multiple remote presenters to control the same running slide deck on a presenting host machine.

Problem
-------
We have regular all-hands meetings with presenters scattered across multiple remote markets. We often resort to the awkward
"next slide, please" routine. This is not ideal.

Solution
--------
This service is a web server which serves a web page with arrow and keyboard controls. It's intended that you run it on the
machine presenting the slides. It will then relay keyboard events to the local machine, controling the running presentation.

Building
--------
Link against openssl:
```
swift build -Xswiftc -I/usr/local/opt/openssl/include -Xswiftc -static-stdlib -Xlinker -L/usr/local/opt/openssl/lib
```

But if we want to run this on a machine without brew's openssl, we need to mess with the output binary:
```
install_name_tool -change /usr/local/opt/openssl/lib/libcrypto.1.0.0.dylib /usr/lib/libcrypto.dylib .build/debug/remote
install_name_tool -change /usr/local/opt/openssl/lib/libssl.1.0.0.dylib /usr/lib/libssl.dylib .build/debug/remote
```

Another option is to `rm -rf /usr/local/opt/openssl/lib/*.dylib` before `swift build`. Then the linker will only find the static libraries available and compile those into a fatter binary.
