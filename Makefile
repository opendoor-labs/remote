I_DIR=/usr/local/opt/openssl/include
L_DIR=/usr/local/opt/openssl/lib

debug: .build/debug/remote
release: .build/release/remote

clean:
	swift package clean
	rm -rf Library

.build/debug/remote: Sources/remote/main.swift
	swift build -Xswiftc -I$(I_DIR) -Xlinker -L$(L_DIR)

.build/release/remote: Library/libssl.a Library/libcrypto.a Sources/remote/main.swift
	swift build -c release -Xswiftc -I$(I_DIR) -Xswiftc -static-stdlib -Xlinker -LLibrary

Library/%.a: $(L_DIR)/%.a | Library
	ln -s $< Library/

Library:
	mkdir Library
