import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hm_core/hm_core.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens a web page outside the app (official notifications, textbook links).
abstract interface class LinkOpener {
  Future<bool> open(String url);
}

class UrlLauncherLinkOpener implements LinkOpener {
  const UrlLauncherLinkOpener();

  @override
  Future<bool> open(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null || !(uri.scheme == 'https' || uri.scheme == 'http')) {
      return Future.value(false);
    }
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

/// Shares plain text through the phone's share sheet.
abstract interface class ShareService {
  Future<void> shareText(String text);
}

class SharePlusService implements ShareService {
  const SharePlusService();

  @override
  Future<void> shareText(String text) async {
    await SharePlus.instance.share(ShareParams(text: text));
  }
}

final linkOpenerProvider = Provider<LinkOpener>(
  (ref) => const UrlLauncherLinkOpener(),
);

final shareServiceProvider = Provider<ShareService>(
  (ref) => const SharePlusService(),
);

/// The simple-English message to show for any failure.
String messageOf(Object error) =>
    error is HmApiException ? error.message : HmApiException.unknownMessage;

/// Grievance contact and legal pages (DPDP, blueprint §23, §30).
const grievanceEmail = 'grievance@heymey.app';
const privacyUrl = 'https://heymey.app/legal/privacy';
const termsUrl = 'https://heymey.app/legal/terms';
