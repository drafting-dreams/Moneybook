#!/bin/bash

flutter pub pub run intl_translation:extract_to_arb --output-dir=lib/l10n lib/locale/locales.dart
