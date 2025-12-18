import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:html' as html;

class AddressPickerDialog extends StatefulWidget {
  final String? initialAddress;
  final Function(String address, double? latitude, double? longitude) onAddressSelected;

  const AddressPickerDialog({
    super.key,
    this.initialAddress,
    required this.onAddressSelected,
  });

  @override
  State<AddressPickerDialog> createState() => _AddressPickerDialogState();
}

class _AddressPickerDialogState extends State<AddressPickerDialog> {
  final TextEditingController _addressController = TextEditingController();
  double? _selectedLatitude;
  double? _selectedLongitude;

  @override
  void initState() {
    super.initState();
    _addressController.text = widget.initialAddress ?? '';
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _openGoogleMaps() async {
    final searchQuery = _addressController.text.trim();
    final url = searchQuery.isNotEmpty
        ? 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(searchQuery)}'
        : 'https://www.google.com/maps';
    
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Google Maps açıldı. Adresi bulduktan sonra buraya yapıştırın.',
              ),
              duration: Duration(seconds: 4),
              backgroundColor: Color(0xFF2196F3),
            ),
          );
        }
      }
    } catch (e) {
      // Fallback: HTML window.open kullan (sadece web için)
      if (kIsWeb) {
        html.window.open(url, 'Google Maps');
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Google Maps açıldı. Adresi bulduktan sonra buraya yapıştırın.',
              ),
              duration: Duration(seconds: 4),
              backgroundColor: Color(0xFF2196F3),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1A2332),
      title: const Text(
        'Adres Seç',
        style: TextStyle(color: Colors.white),
      ),
      content: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Adresi yazın veya haritadan seçin:',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: 'Adres',
                labelStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: const Color(0xFF0A1929),
                hintText: 'Örn: Bandırma, Balıkesir',
                hintStyle: const TextStyle(color: Colors.white38),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.map, color: Color(0xFF2196F3)),
                  onPressed: _openGoogleMaps,
                  tooltip: 'Google Maps\'te Aç',
                ),
              ),
              style: const TextStyle(color: Colors.white),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _openGoogleMaps,
              icon: const Icon(Icons.map),
              label: const Text('Google Maps\'te Aç ve Seç'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFF2196F3)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Google Maps\'te adresi arayın, bulun ve adresi buraya yapıştırın.',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal', style: TextStyle(color: Colors.white70)),
        ),
        ElevatedButton(
          onPressed: _addressController.text.trim().isNotEmpty
              ? () {
                  widget.onAddressSelected(
                    _addressController.text.trim(),
                    _selectedLatitude,
                    _selectedLongitude,
                  );
                  Navigator.pop(context);
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2196F3),
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey,
          ),
          child: const Text('Seç'),
        ),
      ],
    );
  }
}

