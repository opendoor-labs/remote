all: debug

clean:
	swift package clean
	rm -rf Library

debug: .build/debug/remote
release: .build/release/remote

.build/debug/remote:
	swift build -Xswiftc -I/usr/local/opt/openssl/include -Xlinker -L/usr/local/opt/openssl/lib

.build/release/remote: Library/libssl.a Library/libcrypto.a
	swift build -c release -Xswiftc -I/usr/local/opt/openssl/include -Xswiftc -static-stdlib -Xlinker -LLibrary

Library/libssl.a: Library
	ln -s /usr/local/opt/openssl/lib/libssl.a Library/libssl.a

Library/libcrypto.a: Library
	ln -s /usr/local/opt/openssl/lib/libcrypto.a Library/libcrypto.a

Library:
	mkdir Library
