How to cross-build CLI profile

* run `t2 config` and change:

SDECFG_PKGSEL_TMPL='cli'
SDECFG_X8664_OPT='nocona'
SDECFG_CROSSBUILD='1'
SDECFG_CONTINUE_ON_ERROR_AFTER='9

* Build image with:

t2 build-target -cfg crosscli

* Build crosscli.iso and crosscli.sha256
  
t2 create-iso crosscli
