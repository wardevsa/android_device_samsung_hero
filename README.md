# TWRP Device Tree for Samsung Galaxy S7 (herolte)

Adaptado para twrp-12.1 (AOSP minimal manifest) con soporte zip64 (>4GB).
Basado en: https://github.com/ananjaser1211/android_device_samsung_hero (branch: herolte)

## Compilar con GitHub Actions

Usa: https://github.com/pisti87/TWRP-Recovery-Builder-2026

### Parámetros:

| Parámetro | Valor |
|---|---|
| MANIFEST_BRANCH | twrp-12.1 |
| DEVICE_TREE_URL | https://github.com/TU_USER/android_device_samsung_hero.git |
| DEVICE_TREE_BRANCH | main |
| DEVICE_PATH | device/samsung/herolte |
| DEVICE_NAME | herolte |
| DEVICE_MAKEFILE | twrp_herolte |
| BUILD_TARGET | recovery |
| RECOVERY_TAR | true |
