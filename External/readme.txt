First, set FOO to the complete path to External/Build/win32.  This path must not have
any spaces in it, so create a symlink if necessary to ensure that.  Then, set CFLAGS to
"-mno-cygwin -I${FOO}/include -L${FOO}/lib".  Set CXXFLAGS to the same thing.  Also add
${FOO}/bin to PATH.  Then build each library with, ie, ./configure --prefix=${FOO}.
