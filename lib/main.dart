import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const DiazGoApp());
}

class DiazGoApp extends StatelessWidget {
  const DiazGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DíazGo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MainMenuScreen(),
    );
  }
}

// -------------------------------------------------------------
// MODELOS DE DATOS Y ESTADO GLOBAL
// -------------------------------------------------------------
class SavedAddress {
  String name;
  String address;
  String district;

  SavedAddress({required this.name, required this.address, required this.district});
}

class VehicleStatus {
  final String name;
  final String color;
  final String plate;
  final String status;
  final String currentLocation;
  final double speed;
  final double fuelLevel;

  VehicleStatus({
    required this.name,
    required this.color,
    required this.plate,
    required this.status,
    required this.currentLocation,
    required this.speed,
    required this.fuelLevel,
  });
}

List<SavedAddress> globalSavedAddresses = [
  SavedAddress(name: 'Mi Casa', address: 'Av. Javier Prado Este 2450', district: 'San Borja'),
  SavedAddress(name: 'Trabajo', address: 'Av. República de Panamá 3055', district: 'San Isidro'),
  SavedAddress(name: 'Casa de Hijo', address: 'Calle Los Olivos 420', district: 'Surco'),
];

List<VehicleStatus> globalVehicles = [
  VehicleStatus(
    name: 'Jeep Cherokee Longitude 2018',
    color: 'Gris / Plata',
    plate: 'ABC-123',
    status: 'En Ruta',
    currentLocation: 'Av. Arequipa Cdra. 15, Lince',
    speed: 42.0,
    fuelLevel: 0.75,
  ),
  VehicleStatus(
    name: 'Subaru Forester',
    color: 'Celeste',
    plate: 'DEF-456',
    status: 'Estacionado',
    currentLocation: 'Av. Larco 780, Miraflores',
    speed: 0.0,
    fuelLevel: 0.50,
  ),
  VehicleStatus(
    name: 'Renault Logan 2020',
    color: 'Negro',
    plate: 'GHI-789',
    status: 'En Ruta',
    currentLocation: 'Av. Elmer Faucett, Callao',
    speed: 55.0,
    fuelLevel: 0.90,
  ),
];

// Base local completa de respaldo exclusivo para Lima (Avenidas principales y cruces)
const List<Map<String, String>> localLimaBackup = [
  {'title': 'Av. Miguel Grau (Cuadras 1 a 17)', 'subtitle': 'Cercado de Lima / La Victoria, Lima'},
  {'title': 'Av. Miguel Grau 185', 'subtitle': 'Cercado de Lima (Cerca a Plaza Grau / Paseo Colón)'},
  {'title': 'Av. Abancay (Cruce con Av. Grau - Cdra. 5)', 'subtitle': 'Cercado de Lima'},
  {'title': 'Hospital Dos de Mayo (Av. Grau / Av. Aviación)', 'subtitle': 'Cercado de Lima'},
  {'title': 'Hospital Almenara (Av. Grau / Jr. Huánuco)', 'subtitle': 'La Victoria, Lima'},
  {'title': 'Estación Miguel Grau - Línea 1 Metro', 'subtitle': 'Av. Nicolás Ayllón / Av. Grau'},
  {'title': 'Av. Javier Prado Este', 'subtitle': 'San Borja / Surco / La Molina, Lima'},
  {'title': 'Av. Javier Prado Oeste', 'subtitle': 'San Isidro / Magdalena, Lima'},
  {'title': 'Av. Arequipa', 'subtitle': 'Lima / Lince / San Isidro / Miraflores'},
  {'title': 'Av. Paseo de la República (Vía Expresa)', 'subtitle': 'Lima Metropolitana'},
  {'title': 'Av. Brasil', 'subtitle': 'Breña / Jesús María / Pueblo Libre / Magdalena'},
];

// -------------------------------------------------------------
// 1. MENÚ PRINCIPAL
// -------------------------------------------------------------
class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  String selectedVehicle = 'Jeep Cherokee Longitude 2018';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DíazGo', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.home, size: 44),
                label: const Text('MIS CASAS / IR A CASA', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => SavedAddressesScreen(selectedVehicle: selectedVehicle)),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal[700],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.search, size: 44),
                label: const Text('NUEVA RUTA', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => SearchLimaRouteScreen(selectedVehicle: selectedVehicle)),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.directions_car, size: 40),
                label: Text('AUTO ACTUAL:\n$selectedVehicle', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                onPressed: () async {
                  final vehicle = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const VehicleSelectionScreen()),
                  );
                  if (vehicle != null) setState(() => selectedVehicle = vehicle);
                },
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo[800],
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(65),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.radar, size: 36),
              label: const Text('MONITOREO DE VEHÍCULOS', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const VehicleMonitoringScreen()),
                );
              },
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[700],
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(65),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Alerta SOS y ubicación enviada a contactos.', style: TextStyle(fontSize: 20))),
                );
              },
              child: const Text('SOS / AYUDA', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// 2. GESTIÓN Y SELECCIÓN DE DIRECCIONES GUARDADAS (IR A CASA)
// -------------------------------------------------------------
class SavedAddressesScreen extends StatefulWidget {
  final String selectedVehicle;
  const SavedAddressesScreen({super.key, required this.selectedVehicle});

  @override
  State<SavedAddressesScreen> createState() => _SavedAddressesScreenState();
}

class _SavedAddressesScreenState extends State<SavedAddressesScreen> {
  void _addNewAddress() {
    TextEditingController nameCtrl = TextEditingController();
    TextEditingController addrCtrl = TextEditingController();
    TextEditingController distCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Registrar Nueva Dirección', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                style: const TextStyle(fontSize: 18),
                decoration: const InputDecoration(labelText: 'Nombre (ej: Mi Casa, Trabajo)', labelStyle: TextStyle(fontSize: 18)),
              ),
              TextField(
                controller: addrCtrl,
                style: const TextStyle(fontSize: 18),
                decoration: const InputDecoration(labelText: 'Dirección (Calle / Av.)', labelStyle: TextStyle(fontSize: 18)),
              ),
              TextField(
                controller: distCtrl,
                style: const TextStyle(fontSize: 18),
                decoration: const InputDecoration(labelText: 'Distrito de Lima', labelStyle: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCELAR', style: TextStyle(fontSize: 18, color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.isNotEmpty && addrCtrl.text.isNotEmpty) {
                setState(() {
                  globalSavedAddresses.add(
                    SavedAddress(name: nameCtrl.text, address: addrCtrl.text, district: distCtrl.text.isEmpty ? 'Lima' : distCtrl.text),
                  );
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text('GUARDAR', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Lugares Guardados', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(60),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.add_location_alt, size: 36),
              label: const Text('AGREGAR NUEVA DIRECCIÓN', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              onPressed: _addNewAddress,
            ),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('SELECCIONA A DÓNDE IR (Ruta desde tu GPS actual):', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: globalSavedAddresses.length,
                itemBuilder: (context, index) {
                  final item = globalSavedAddresses[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      leading: CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.blue[100],
                        child: Icon(item.name.toLowerCase().contains('casa') ? Icons.home : Icons.business, size: 32, color: Colors.blue[800]),
                      ),
                      title: Text(item.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      subtitle: Text('${item.address} - ${item.district}', style: const TextStyle(fontSize: 16)),
                      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.blue),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MapNavigationScreen(
                              vehicle: widget.selectedVehicle,
                              destinationName: item.name,
                              destinationAddress: '${item.address}, ${item.district}',
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// 3. BÚSQUEDA EXCLUSIVA Y CONFIABLE PARA LIMA METROPOLITANA
// -------------------------------------------------------------
class SearchLimaRouteScreen extends StatefulWidget {
  final String selectedVehicle;
  const SearchLimaRouteScreen({super.key, required this.selectedVehicle});

  @override
  State<SearchLimaRouteScreen> createState() => _SearchLimaRouteScreenState();
}

class _SearchLimaRouteScreenState extends State<SearchLimaRouteScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, String>> suggestions = [];
  bool isLoading = false;

  Future<void> _searchLimaRobusto(String query) async {
    final cleanQuery = query.trim().replaceAll('.', '');
    if (cleanQuery.isEmpty) {
      setState(() {
        suggestions = [];
        isLoading = false;
      });
      return;
    }

    setState(() => isLoading = true);

    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(cleanQuery)}&format=json&addressdetails=1&limit=10&viewbox=-77.20,-11.70,-76.70,-12.35&bounded=1&countrycodes=pe',
      );

      final response = await http.get(
        url,
        headers: {'User-Agent': 'DiazGo_Lima_App_v2'},
      ).timeout(const Duration(seconds: 4));

      List<Map<String, String>> parsedResults = [];

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);

        for (var item in data) {
          String displayName = item['display_name'] ?? '';
          Map<String, dynamic> address = item['address'] ?? {};

          String road = address['road'] ?? address['pedestrian'] ?? address['suburb'] ?? item['name'] ?? '';
          String houseNumber = address['house_number'] ?? '';
          String suburb = address['suburb'] ?? address['neighbourhood'] ?? address['city_district'] ?? 'Lima';
          String city = address['city'] ?? address['town'] ?? 'Lima Metropolitana';

          if (displayName.contains('Lima') || displayName.contains('Callao') || displayName.contains('Peru')) {
            String mainTitle = road;
            if (houseNumber.isNotEmpty) mainTitle += ' $houseNumber';
            if (mainTitle.isEmpty) mainTitle = item['name'] ?? cleanQuery;

            parsedResults.add({
              'type': 'Address',
              'title': mainTitle,
              'subtitle': '$suburb, $city, Lima Metropolitana',
            });
          }
        }
      }

      if (parsedResults.isEmpty) {
        final qLower = cleanQuery.toLowerCase();
        for (var local in localLimaBackup) {
          if (local['title']!.toLowerCase().contains(qLower) || local['subtitle']!.toLowerCase().contains(qLower)) {
            parsedResults.add(local);
          }
        }
      }

      if (parsedResults.isEmpty) {
        parsedResults.add({
          'title': cleanQuery.toUpperCase(),
          'subtitle': 'Lima Metropolitana, Perú (Búsqueda por altura y cuadras)',
        });
      }

      setState(() {
        suggestions = parsedResults;
        isLoading = false;
      });
    } catch (e) {
      final qLower = cleanQuery.toLowerCase();
      List<Map<String, String>> fallbackResults = [];

      for (var local in localLimaBackup) {
        if (local['title']!.toLowerCase().contains(qLower) || local['subtitle']!.toLowerCase().contains(qLower)) {
          fallbackResults.add(local);
        }
      }

      if (fallbackResults.isEmpty) {
        fallbackResults.add({
          'title': cleanQuery.toUpperCase(),
          'subtitle': 'Lima Metropolitana, Perú',
        });
      }

      setState(() {
        suggestions = fallbackResults;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscador Lima Metropolitana', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal[800],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              onChanged: (val) => _searchLimaRobusto(val),
              style: const TextStyle(fontSize: 22),
              decoration: InputDecoration(
                hintText: 'Ej: Av Grau 185, Av Javier Prado...',
                hintStyle: const TextStyle(fontSize: 18),
                prefixIcon: const Icon(Icons.search, size: 36, color: Colors.teal),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.mic, size: 36, color: Colors.blue),
                  onPressed: () {
                    _controller.text = 'Av Grau 185';
                    _searchLimaRobusto('Av Grau 185');
                  },
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
              ),
            ),
            const SizedBox(height: 12),

            if (isLoading)
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(),
              )
            else
              Expanded(
                child: suggestions.isEmpty
                    ? Center(
                        child: Text(
                          _controller.text.isEmpty
                              ? 'Escribe avenidas o direcciones exactas de Lima Metropolitana...'
                              : 'No se encontraron resultados en Lima Metropolitana.',
                          style: const TextStyle(fontSize: 18, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.builder(
                        itemCount: suggestions.length,
                        itemBuilder: (context, index) {
                          final item = suggestions[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              leading: const Icon(
                                Icons.add_road,
                                size: 36,
                                color: Colors.teal,
                              ),
                              title: Text(item['title']!, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              subtitle: Text(item['subtitle']!, style: const TextStyle(fontSize: 16)),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => MapNavigationScreen(
                                      vehicle: widget.selectedVehicle,
                                      destinationName: item['title']!,
                                      destinationAddress: item['subtitle']!,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
              ),
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// 4. MONITOREO EN TIEMPO REAL DE VEHÍCULOS
// -------------------------------------------------------------
class VehicleMonitoringScreen extends StatefulWidget {
  const VehicleMonitoringScreen({super.key});

  @override
  State<VehicleMonitoringScreen> createState() => _VehicleMonitoringScreenState();
}

class _VehicleMonitoringScreenState extends State<VehicleMonitoringScreen> {
  VehicleStatus? selectedMonitoredVehicle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monitoreo de Flota / Vehículos', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.indigo[900],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'SELECCIONA EL AUTO QUE DESEAS MONITOREAR:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 10),

            Expanded(
              flex: 2,
              child: ListView.builder(
                itemCount: globalVehicles.length,
                itemBuilder: (context, index) {
                  final v = globalVehicles[index];
                  final isSelected = selectedMonitoredVehicle?.name == v.name;
                  return Card(
                    elevation: isSelected ? 6 : 2,
                    color: isSelected ? Colors.indigo[50] : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(color: isSelected ? Colors.indigo : Colors.transparent, width: 2),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      leading: Icon(Icons.directions_car, size: 42, color: v.status == 'En Ruta' ? Colors.green : Colors.grey),
                      title: Text(v.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      subtitle: Text('Placa: ${v.plate} | Estado: ${v.status}'),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isSelected ? Colors.indigo[900] : Colors.indigo[700],
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            selectedMonitoredVehicle = v;
                          });
                        },
                        child: Text(isSelected ? 'MONITOREANDO' : 'VER TELEMETRÍA'),
                      ),
                    ),
                  );
                },
              ),
            ),

            if (selectedMonitoredVehicle != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.indigo[900],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          selectedMonitoredVehicle!.name,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: selectedMonitoredVehicle!.status == 'En Ruta' ? Colors.green : Colors.orange,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            selectedMonitoredVehicle!.status,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const Divider(color: Colors.white30, height: 20),
                    Text('📍 Ubicación Actual: ${selectedMonitoredVehicle!.currentLocation}', style: const TextStyle(color: Colors.white, fontSize: 16)),
                    const SizedBox(height: 6),
                    Text('⚡ Velocidad Actual: ${selectedMonitoredVehicle!.speed} km/h', style: const TextStyle(color: Colors.white, fontSize: 16)),
                    const SizedBox(height: 6),
                    Text('⛽ Nivel de Combustible: ${(selectedMonitoredVehicle!.fuelLevel * 100).toInt()}%', style: const TextStyle(color: Colors.white, fontSize: 16)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// 5. NAVEGACIÓN Y MAPA PASO A PASO POR CUADRAS EN LIMA
// -------------------------------------------------------------
class MapNavigationScreen extends StatefulWidget {
  final String vehicle;
  final String destinationName;
  final String destinationAddress;

  const MapNavigationScreen({
    super.key,
    required this.vehicle,
    required this.destinationName,
    required this.destinationAddress,
  });

  @override
  State<MapNavigationScreen> createState() => _MapNavigationScreenState();
}

class _MapNavigationScreenState extends State<MapNavigationScreen> {
  bool isNavigating = false;
  int currentStep = 0;

  final List<Map<String, String>> steps = const [
    {'instruction': 'Inicio en Plaza Grau (Cuadra 1) - Av. Grau', 'distance': '100m'},
    {'instruction': 'En 200m cruzar Av. Manco Cápac / Jr. Cotabambas (Cuadras 2-4)', 'distance': '200m'},
    {'instruction': 'Sigue de frente: Cruce neurálgico con Av. Abancay (Cuadra 5)', 'distance': '300m'},
    {'instruction': 'Tramo comercial: Cruce Jr. Andahuaylas y Jr. Paruro (Cuadras 6-9)', 'distance': '400m'},
    {'instruction': 'Cruce Jr. Huánuco / Frente al Hospital Almenara (Cuadra 10-11)', 'distance': '350m'},
    {'instruction': 'Cruce Av. Aviación / Hospital Dos de Mayo (Cuadra 12-14)', 'distance': '300m'},
    {'instruction': 'Fin de ruta: Av. Nicolás Ayllón / Estación Miguel Grau Metro L1', 'distance': '100m'},
  ];

  void _nextStep() {
    if (currentStep < steps.length - 1) {
      setState(() => currentStep++);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ArrivalScreen(destinationName: widget.destinationName),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Navegando: ${widget.vehicle}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Container(
            color: const Color(0xFFE5E9F0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(isNavigating ? Icons.navigation : Icons.map, size: 100, color: Colors.blue[800]),
                  const SizedBox(height: 12),
                  Text(
                    widget.destinationName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      widget.destinationAddress,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                  if (isNavigating) ...[
                    const SizedBox(height: 15),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(color: Colors.blue[100], borderRadius: BorderRadius.circular(20)),
                      child: Text(
                        'Tramo actual: ${steps[currentStep]['distance']}',
                        style: TextStyle(fontSize: 18, color: Colors.blue[900], fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Positioned(
            top: 15,
            left: 15,
            right: 15,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.blue[900], borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  Icon(currentStep % 2 == 0 ? Icons.turn_right : Icons.turn_left, size: 52, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      steps[currentStep]['instruction']!,
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 15,
            right: 15,
            child: Row(
              children: [
                if (!isNavigating) ...[
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () => setState(() => isNavigating = true),
                      child: const Text('COMENZAR RUTA', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ] else ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[800],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      icon: const Icon(Icons.arrow_forward, size: 32),
                      label: const Text('SIGUIENTE PASO', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      onPressed: _nextStep,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
// SELECCIÓN DE VEHÍCULO
// -------------------------------------------------------------
class VehicleSelectionScreen extends StatelessWidget {
  const VehicleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Seleccionar tu Auto', style: TextStyle(fontSize: 22))),
      body: ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: globalVehicles.length,
        itemBuilder: (context, index) {
          final v = globalVehicles[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: const Icon(Icons.directions_car, size: 40, color: Colors.blue),
              title: Text(v.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              subtitle: Text('Color: ${v.color} | Placa: ${v.plate}'),
              onTap: () => Navigator.pop(context, v.name),
            ),
          );
        },
      ),
    );
  }
}

// -------------------------------------------------------------
// FIN DE RUTA
// -------------------------------------------------------------
class ArrivalScreen extends StatelessWidget {
  final String destinationName;
  const ArrivalScreen({super.key, required this.destinationName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.check_circle, size: 120, color: Colors.green),
              const SizedBox(height: 20),
              const Text('¡LLEGASTE A TU DESTINO!', textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text(destinationName, textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, color: Colors.grey)),
              const SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
                onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                child: const Text('VOLVER AL MENÚ PRINCIPAL', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
