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
We want to statically link OpenSSL. So, first `brew install openssl`. Then, hide the shared OpenSSL libraries from the linker:
```
mkdir Library
ln -s /usr/local/opt/openssl/lib/libssl.a Library
ln -s /usr/local/opt/openssl/lib/libcrypto.a Library
swift build -Xswiftc -I/usr/local/opt/openssl/include -Xswiftc -static-stdlib -Xlinker -LLibrary
```
