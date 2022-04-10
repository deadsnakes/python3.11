
if dpkg-vendor --derives-from Ubuntu; then
  vendor=Ubuntu
elif dpkg-vendor --derives-from Debian; then
  vendor=Debian
else
  vendor=Unknown
fi

export LOCPATH=$(pwd)/locales
sh $debian_dir/locale-gen

export LANG=C.UTF-8

export DEB_PYTHON_INSTALL_LAYOUT=deb_system

TESTOPTS="-j 1 -w -uall,-network,-urlfetch,-gui"

# test_dbm: Fails from time to time ...
#TESTEXCLUSIONS="$TESTEXCLUSIONS test_dbm"

# test_ensurepip: not yet installed, http://bugs.debian.org/732703
# ... and then test_venv fails too
TESTEXCLUSIONS="$TESTEXCLUSIONS test_ensurepip test_venv "

# test_lib2to3: see https://bugs.python.org/issue34286
TESTEXCLUSIONS="$TESTEXCLUSIONS test_lib2to3"

# test_tcl: see https://bugs.python.org/issue34178
TESTEXCLUSIONS="$TESTEXCLUSIONS test_tcl"

# FIXME: flaky/slow test?
if [ "$vendor" = Debian ]; then
  TESTEXCLUSIONS="$TESTEXCLUSIONS test_asyncio"
fi

# FIXME: testWithTimeoutTriggeredSend: timeout not raised by _sendfile_use_sendfile
TESTEXCLUSIONS="$TESTEXCLUSIONS test_socket"

# FIXME, failing on the Ubuntu autopkg testers
if [ "$vendor" = Ubuntu ]; then
  TESTEXCLUSIONS="$TESTEXCLUSIONS test_code_module"
fi

# test_ssl currently assumes that OpenSSL is compiled with SECURITY_LEVEL=1
# set security level to 1 for now, to make test_ssl pass
export OPENSSL_CONF=$debian_dir/openssl.cnf

# FIXME: Fails with Ubuntu's autopkg test infrastructure
if [ "$vendor" = Ubuntu ]; then
  if [ "$(dpkg --print-architecture)" = arm64 ]; then
    TESTEXCLUSIONS="$TESTEXCLUSIONS test_io"
  fi
fi

# FIXME: test_ttk_guionly times out on many buildds
TESTEXCLUSIONS="$TESTEXCLUSIONS test_ttk_guionly"

# FIXME: test_ttk_textonly started failing in 3.9.1 rc1
TESTEXCLUSIONS="$TESTEXCLUSIONS test_ttk_textonly"

# FIXME: test_multiprocessing_fork times out sometimes. See #1000188
TESTEXCLUSIONS="$TESTEXCLUSIONS test_multiprocessing_fork"
