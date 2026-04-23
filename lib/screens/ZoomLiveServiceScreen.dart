import 'package:flutter/material.dart';
import 'package:higherground/service/zoom_service.dart';
import 'package:higherground/utils/my_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class ZoomLiveServiceScreen extends StatefulWidget {
  static const routeName = "/zoom_live_service";

  const ZoomLiveServiceScreen({Key? key}) : super(key: key);

  @override
  State<ZoomLiveServiceScreen> createState() => _ZoomLiveServiceScreenState();
}

class _ZoomLiveServiceScreenState extends State<ZoomLiveServiceScreen> {
  static const String _meetingTitle = 'Sunday Night Prayer Meeting';

  late Future<ZoomServiceStatus> _zoomServiceFuture;

  @override
  void initState() {
    super.initState();
    _zoomServiceFuture = ZoomService.fetchZoomServiceStatus();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkZoomStatus();
    });
  }

  Future<void> checkZoomStatus() async {
    try {
      final data = await ZoomService.fetchZoomServiceStatus();

      if (!mounted) return;

      if (data.isLive) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text(
              _meetingTitle,
              style: TextStyle(color: Colors.purple),
            ),
            content: const Text('Zoom service is now live.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  if (data.meetingUrl != null && data.meetingUrl!.isNotEmpty) {
                    await _launchUrl(data.meetingUrl!);
                  } else {
                    _showSnackBar('Meeting URL not available', isError: true);
                  }
                },
                child: const Text('Join Meeting'),
              ),
            ],
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Service Not Live'),
            content: const Text(
              _meetingTitle,
              style: TextStyle(color: Colors.purple),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Failed to check Zoom status: $e', isError: true);
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null || !(uri.hasScheme && uri.hasAuthority)) {
      throw 'Invalid meeting URL';
    }

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch meeting URL';
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _refreshZoomStatus() {
    setState(() {
      _zoomServiceFuture = ZoomService.fetchZoomServiceStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          _meetingTitle,
          style: TextStyle(color: Colors.purple),
        ),
        centerTitle: true,
        backgroundColor: MyColors.mainC0lor,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              _refreshZoomStatus();
              await checkZoomStatus();
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _refreshZoomStatus();
        },
        child: FutureBuilder<ZoomServiceStatus>(
          future: _zoomServiceFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingWidget();
            }

            if (snapshot.hasError) {
              return _buildErrorWidget(snapshot.error.toString());
            }

            if (!snapshot.hasData) {
              return _buildErrorWidget('No data available');
            }

            ZoomServiceStatus status = snapshot.data!;

            if (status.isLive) {
              return _buildLiveWidget(status);
            } else {
              return _buildOfflineWidget(status);
            }
          },
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            strokeWidth: 4,
            valueColor:
                AlwaysStoppedAnimation<Color>(MyColors.mainC0lor),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading service status...',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to Load Service',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _refreshZoomStatus,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: MyColors.mainC0lor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveWidget(ZoomServiceStatus status) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 24),
            _buildTopBannerImage(),
            const SizedBox(height: 16),
            const Text(
              _meetingTitle,
              style: TextStyle(
                color: Colors.purple,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // Live Indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(2.0),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.red),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'LIVE NOW',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const SizedBox(height: 8),
            // Primary Join Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (status.meetingUrl != null &&
                      status.meetingUrl!.isNotEmpty) {
                    try {
                      await _launchUrl(status.meetingUrl!);
                    } catch (e) {
                      _showSnackBar('Error opening zoom: $e', isError: true);
                    }
                  } else {
                    _showSnackBar(
                      'Meeting URL not available',
                      isError: true,
                    );
                  }
                },
                child: const Text('Join Meeting'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Information Card
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.info,
                      color: Colors.blue.shade700,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Ensure you have a stable internet connection for the best experience.',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfflineWidget(ZoomServiceStatus status) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 24),
            _buildTopBannerImage(),
            const SizedBox(height: 16),
            const Text(
              _meetingTitle,
              style: TextStyle(
                color: Colors.purple,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            // Offline Indicator
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: Text(
                'OFFLINE',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Offline Message
            Text(
              'Service Not Live',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: null,
                child: const Text('Join Meeting'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade300,
                  foregroundColor: Colors.grey.shade600,
                  disabledForegroundColor: Colors.grey.shade600,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Join link appears when service goes live and meeting_url is available.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Card(
              color: Colors.amber.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          color: Colors.amber.shade700,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Please check back by service time.',
                            style: TextStyle(
                              color: Colors.amber.shade700,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Next Service Info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Next Service',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Every Sunday at 8:00 PM',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.info_outline, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Pull down to refresh and check if service is now live',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade600,
                              ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBannerImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        color: Colors.grey.shade100,
        child: Image.asset(
          'assets/images/pastor-sola-oladipo.webp',
          width: double.infinity,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                alignment: Alignment.center,
                color: Colors.grey.shade200,
                child: Text(
                  'Banner image unavailable',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}



