import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sentinelle_ci/viewmodels/report_viewmodel.dart';
import 'package:sentinelle_ci/utils/app_colors.dart';
import 'package:sentinelle_ci/models/report_model.dart';
import 'package:sentinelle_ci/views/report_detail_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  ll.LatLng _currentCenter = const ll.LatLng(5.3484, -4.0305);
  ReportViewModel? _reportViewModel;

  @override
  void initState() {
    super.initState();
    _recenterOnUser();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final vm = Provider.of<ReportViewModel>(context);
    if (_reportViewModel != vm) {
      _reportViewModel?.removeListener(_onReportChanged);
      _reportViewModel = vm;
      _reportViewModel?.addListener(_onReportChanged);
    }
  }

  @override
  void dispose() {
    _reportViewModel?.removeListener(_onReportChanged);
    super.dispose();
  }

  void _onReportChanged() {
    if (_reportViewModel?.lastCreatedReport != null) {
      final report = _reportViewModel!.lastCreatedReport!;
      _mapController.move(ll.LatLng(report.latitude, report.longitude), 13.0);
      Future.delayed(Duration.zero, () {
        _reportViewModel?.clearLastReport();
      });
    }
  }

  Future<void> _recenterOnUser() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      _mapController.move(ll.LatLng(position.latitude, position.longitude), 14.0);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible de récupérer votre position GPS')),
      );
    }
  }

  Color _getMarkerColor(ReportModel report) {
    if (report.isUrgent) return Colors.red;
    switch (report.category) {
      case ReportCategory.routes: return Colors.orange;
      case ReportCategory.waste: return Colors.brown;
      case ReportCategory.water: return Colors.blue;
      case ReportCategory.lighting: return Colors.amber;
      default: return AppColors.primaryGreen;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carte des Incidents', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _recenterOnUser,
          ),
        ],
      ),
      body: Stack(
        children: [
          Consumer<ReportViewModel>(
            builder: (context, vm, child) {
              return FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _currentCenter,
                  initialZoom: 12.0,
                  onPositionChanged: (pos, hasGesture) {
                    if (pos.center != null) {
                      _currentCenter = ll.LatLng(pos.center!.latitude, pos.center!.longitude);
                    }
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.sentinelleci.app',
                  ),
                  MarkerLayer(
                    markers: vm.reports.map((report) {
                      final color = _getMarkerColor(report);
                      return Marker(
                        point: ll.LatLng(report.latitude, report.longitude),
                        width: 60,
                        height: 60,
                        child: GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => ReportDetailScreen(report: report)),
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 4)],
                                ),
                                child: Icon(
                                  report.isUrgent ? Icons.warning : Icons.location_on,
                                  color: color,
                                  size: 25,
                                ),
                              ),
                              CustomPaint(
                                size: const Size(10, 10),
                                painter: TrianglePainter(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              );
            },
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildLegendItem(Colors.red, 'Urgent'),
                      _buildLegendItem(Colors.orange, 'Routes'),
                      _buildLegendItem(Colors.blue, 'Eau'),
                      _buildLegendItem(AppColors.primaryGreen, 'Autres'),
                    ],
                  ),
                ),
                FloatingActionButton.small(
                  backgroundColor: AppColors.primaryGreen,
                  elevation: 4,
                  onPressed: () {
                    context.read<ReportViewModel>().fetchReports();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Mise à jour de la carte...'), duration: Duration(seconds: 1))
                    );
                  },
                  child: const Icon(Icons.refresh, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class TrianglePainter extends CustomPainter {
  final Color color;
  TrianglePainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width / 2, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
