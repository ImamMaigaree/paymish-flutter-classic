import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../apis/base_model.dart';
import '../../../apis/dic_params.dart';
import '../../../apis/apimanager/user_api_manager.dart';
import '../../../utils/dimens.dart';
import '../../../utils/dialog_utils.dart';
import '../../../utils/preference_key.dart';
import '../../../utils/preference_utils.dart';
import '../../../widgets/one_trust_appbar.dart';
import '../../../widgets/one_trust_primary_button.dart';
import 'model/req_igree_kyc_exchange.dart';

class IgreeConsentScreen extends StatefulWidget {
  final String authorizationUrl;
  final String sessionId;
  final String bvnNumber;

  const IgreeConsentScreen({
    super.key,
    required this.authorizationUrl,
    required this.sessionId,
    required this.bvnNumber,
  });

  @override
  State<IgreeConsentScreen> createState() => _IgreeConsentScreenState();
}

class _IgreeConsentScreenState extends State<IgreeConsentScreen> {
  late final WebViewController _webViewController;
  final WebViewCookieManager _cookieManager = WebViewCookieManager();
  Uri? _authorizationUri;
  Uri? _configuredRedirectUri;
  bool _isCompleting = false;
  bool _isLaunchingBrowser = false;
  bool _isPreparingWebView = true;
  String? _loadingError;

  @override
  void initState() {
    super.initState();
    final authorizationUri = Uri.tryParse(widget.authorizationUrl);
    _authorizationUri = authorizationUri;
    final redirectUri = authorizationUri?.queryParameters['redirect_uri'];
    _configuredRedirectUri = redirectUri == null ? null : Uri.tryParse(redirectUri);

    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            final uri = Uri.tryParse(request.url);
            if (uri == null) {
              return NavigationDecision.navigate;
            }

            if (_isIgreeCallback(uri)) {
              if (uri.queryParameters.containsKey(DicParams.error)) {
                _handleIgreeError(uri);
                return NavigationDecision.prevent;
              }

              _completeVerification(uri);
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
          onWebResourceError: (error) {
            debugPrint(
              'IGREE webview error code=${error.errorCode} '
              'description=${error.description} '
              'url=${error.url ?? "unknown"}',
            );
            if (!mounted) {
              return;
            }

            setState(() {
              _loadingError = 'Unable to load iGree page.\n${error.description}';
            });
          },
        ),
      );

    _prepareAndLoadWebView();
  }

  Future<void> _prepareAndLoadWebView() async {
    try {
      await _cookieManager.clearCookies();
      await _webViewController.clearCache();
      await _webViewController.clearLocalStorage();
      await _webViewController.loadRequest(Uri.parse(widget.authorizationUrl));

      if (!mounted) {
        return;
      }

      setState(() {
        _isPreparingWebView = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isPreparingWebView = false;
        _loadingError = 'Unable to start iGree consent.\n$error';
      });
    }
  }

  bool _isIgreeCallback(Uri uri) {
    final hasOAuthResponse = uri.queryParameters.containsKey(DicParams.code) ||
        uri.queryParameters.containsKey(DicParams.error);
    if (!hasOAuthResponse) {
      return false;
    }

    if (_matchesConfiguredRedirect(uri)) {
      return true;
    }

    return _matchesFallbackRedirect(uri);
  }

  bool _matchesConfiguredRedirect(Uri uri) {
    final configured = _configuredRedirectUri;
    if (configured == null) {
      return false;
    }

    return configured.scheme == uri.scheme &&
        configured.host == uri.host &&
        _normalizePath(configured.path) == _normalizePath(uri.path);
  }

  bool _matchesFallbackRedirect(Uri uri) {
    const fallbackPaths = <String>[
      '/v1/kyc/providers/igree/callback',
      '/api/user-service/v1/login_redirect',
    ];

    final normalizedPath = _normalizePath(uri.path);
    return fallbackPaths.any((path) => normalizedPath.endsWith(_normalizePath(path)));
  }

  String _normalizePath(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed == '/') {
      return '/';
    }

    return trimmed.endsWith('/') ? trimmed.substring(0, trimmed.length - 1) : trimmed;
  }

  void _handleIgreeError(Uri uri) {
    if (!mounted) {
      return;
    }

    final error = uri.queryParameters[DicParams.error];
    final description = uri.queryParameters['error_description'];
    final message = [
      if (error != null && error.isNotEmpty) error,
      if (description != null && description.isNotEmpty) description,
    ].join(': ');

    DialogUtils.showAlertDialog(
      context,
      message.isEmpty ? 'BVN consent was not completed.' : message,
    );
  }

  Future<void> _openInExternalBrowser() async {
    final authorizationUri = _authorizationUri;
    if (authorizationUri == null || _isLaunchingBrowser) {
      return;
    }

    setState(() {
      _isLaunchingBrowser = true;
    });

    try {
      final launched = await launchUrl(
        authorizationUri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && mounted) {
        DialogUtils.showAlertDialog(
          context,
          'Unable to open the device browser for the iGree consent page.',
        );
      }
    } catch (error) {
      if (mounted) {
        DialogUtils.showAlertDialog(
          context,
          'Unable to open the device browser.\n$error',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLaunchingBrowser = false;
        });
      }
    }
  }

  Widget _buildLoadingErrorState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(spacingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Unable to load BVN consent',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: spacingMedium),
            Text(
              _loadingError!,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: spacingLarge),
            OneTrustPrimaryButton(
              buttonText: _isLaunchingBrowser
                  ? 'Opening Browser...'
                  : 'Open in Browser',
              isBackground: true,
              onButtonClick: _isLaunchingBrowser ? () {} : _openInExternalBrowser,
            ),
            const SizedBox(height: spacingMedium),
            Text(
              'Use this only to test whether the iGree page can load outside the in-app browser.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _completeVerification(Uri uri) async {
    if (_isCompleting) {
      return;
    }

    final code = uri.queryParameters[DicParams.code];
    final sessionId = uri.queryParameters[DicParams.state] ?? widget.sessionId;
    if (code == null || code.isEmpty) {
      if (!mounted) {
        return;
      }

      DialogUtils.showAlertDialog(
        context,
        'iGree did not return an authorization code.',
      );
      return;
    }

    setState(() {
      _isCompleting = true;
    });

    try {
      final result = await UserApiManager().completeIgreeKyc(
        ReqIgreeKycExchange(
          userId: getInt(PreferenceKey.id),
          sessionId: sessionId,
          code: code,
          bvnNumber: widget.bvnNumber,
        ),
      );

      final payload = result.data;
      if (!mounted) {
        return;
      }

      if (payload == null || payload.status != DicParams.validated) {
        DialogUtils.showAlertDialog(
          context,
          result.message ?? 'BVN verification was not completed.',
        );
        setState(() {
          _isCompleting = false;
        });
        return;
      }

      await setString(
        PreferenceKey.kycStatus,
        payload.kycStatus ?? DicParams.verified,
      );
      await setString(
        PreferenceKey.bvnNumber,
        payload.bvnNumber ?? widget.bvnNumber,
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(payload);
    } catch (e) {
      if (!mounted) {
        return;
      }

      if (e is ResBaseModel) {
        DialogUtils.showAlertDialog(
          context,
          e.error ?? e.message ?? 'BVN verification failed.',
        );
      } else {
        DialogUtils.showAlertDialog(context, e.toString());
      }

      setState(() {
        _isCompleting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: OneTrustAppBar(
        title: 'BVN Consent',
        isBackGround: false,
      ),
      body: Stack(
        children: [
          if (_loadingError == null)
            WebViewWidget(controller: _webViewController)
          else
            _buildLoadingErrorState(),
          if (_isPreparingWebView || _isCompleting || _isLaunchingBrowser)
            Container(
              color: const Color(0x80000000),
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
