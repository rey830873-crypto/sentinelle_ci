import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sentinelle_ci/viewmodels/report_viewmodel.dart';
import 'package:sentinelle_ci/utils/app_colors.dart';
import 'package:sentinelle_ci/views/report_detail_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carte des incidents', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
      ),
      body: Consumer<ReportViewModel>(
        builder: (context, vm, child) {
          return GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(5.3484, -4.0533), // Abidjan
              zoom: 12,
            ),
            myLocationEnabled: true,
            markers: vm.reports.map((report) {
              return Marker(
                markerId: MarkerId(report.id),
                position: LatLng(report.latitude, report.longitude),
                infoWindow: InfoWindow(
                  title: report.title,
                  snippet: report.category.name,
                  onTap: () => Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (_) => ReportDetailScreen(report: report))
                  ),
                ),
              );
            }).toSet(),
          );
        },
      ),
    );
  }
}
