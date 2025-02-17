{ lib
, buildPythonPackage
, fetchPypi
, fetchpatch
, pythonOlder
, asn1crypto
, cffi
, cryptography
, ibm-sw-tpm2
, pkgconfig # see nativeBuildInputs
, pkg-config # see nativeBuildInputs
, pycparser
, pytestCheckHook
, python
, pyyaml
, setuptools-scm
, tpm2-tss
}:

buildPythonPackage rec {
  pname = "tpm2-pytss";
  version = "2.1.0";
  format = "setuptools";

  disabled = pythonOlder "3.7";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-W1tLFFb9wa7vPSw5cL6qB4yPfyZIyXppvPYMWi+VyJc=";
  };

  patches = [
    # This patches the call to the C preprocessor not to include types
    # pycparser does not handle.
    # `hardeningDisable = [ "fortify" ]` would have the same effect but
    # would also disable hardening from generated FFI objects.
    #
    # backport of https://github.com/tpm2-software/tpm2-pytss/pull/523
    (fetchpatch {
      url = "https://github.com/baloo/tpm2-pytss/commit/099c069f28cfcd0a3019adebfeafa976f9395221.patch";
      sha256 = "sha256-wU2WfLYFDmkhGzYornZ386tB3zb3GYfGOTc+/QOFb1o=";
    })
  ];

  nativeBuildInputs = [
    cffi
    pkgconfig # this is the Python module
    pkg-config # this is the actual pkg-config tool
    setuptools-scm
  ];

  buildInputs = [
    tpm2-tss
  ];

  propagatedBuildInputs = [
    cffi
    asn1crypto
    cryptography
    pyyaml
  ];

  # https://github.com/tpm2-software/tpm2-pytss/issues/341
  doCheck = false;

  nativeCheckInputs = [
    ibm-sw-tpm2
    pytestCheckHook
  ];

  pythonImportsCheck = [
    "tpm2_pytss"
  ];

  meta = with lib; {
    homepage = "https://github.com/tpm2-software/tpm2-pytss";
    changelog = "https://github.com/tpm2-software/tpm2-pytss/blob/${version}/CHANGELOG.md";
    description = "TPM2 TSS Python bindings for Enhanced System API (ESYS)";
    license = licenses.bsd2;
    maintainers = with maintainers; [ baloo ];
  };
}
