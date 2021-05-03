SCRIPT_DIR=$(cd $(dirname $0);pwd)
CONFIGS_DIR=${SCRIPT_DIR}/Configs
if [ ! -d ${CONFIGS_DIR} ]; then
  mkdir ${CONFIGS_DIR}
fi

# ワークアラウンド用の xcconfig ファイルを設定する
export XCODE_XCCONFIG_FILE=${CONFIGS_DIR}/carthage_workaround_for_xcode12.xcconfig
echo 'EXCLUDED_ARCHS__EFFECTIVE_PLATFORM_SUFFIX_simulator__NATIVE_ARCH_64_BIT_x86_64=arm64 arm64e armv7 armv7s armv6 armv8' > ${XCODE_XCCONFIG_FILE}
echo 'EXCLUDED_ARCHS=$(inherited) $(EXCLUDED_ARCHS__EFFECTIVE_PLATFORM_SUFFIX_$(EFFECTIVE_PLATFORM_SUFFIX)__NATIVE_ARCH_64_BIT_$(NATIVE_ARCH_64_BIT))' >> ${XCODE_XCCONFIG_FILE}

# Carthage を実行する
mint run Carthage carthage $@
