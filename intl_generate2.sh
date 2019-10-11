#!/bin/bash

flutter pub pub run intl_translation:generate_from_arb --output-dir=lib/l10n --no-use-deferred-loading lib/l10n/intl_en.arb lib/l10n/intl_zh.arb lib/l10n/intl_messages.arb lib/locale/locales.dart