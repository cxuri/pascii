import 'package:flutter/material.dart';
import 'package:pascii/services/asset_loader.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

class SelectApp extends StatefulWidget {
  @override
  _SelectAppState createState() => _SelectAppState();
}

class _SelectAppState extends State<SelectApp> {
  final TextEditingController _controller = TextEditingController();
  final AssetLoader _assetLoader = AssetLoader();

  late Map<String, String> _assets;
  List<Map<String, String>> filteredApps = [];
  List<String> favourites = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _assets = _assetLoader.load();
    filterValidAssets();
    loadFavourites();
  }

  // Validate if the image asset exists
  Future<bool> isValidAsset(String path) async {
    try {
      await rootBundle.load(path);
      return true;
    } catch (_) {
      return false;
    }
  }

  // Filter out invalid image assets
  void filterValidAssets() async {
    List<Map<String, String>> validApps = [];
    for (var entry in _assets.entries) {
      if (await isValidAsset(entry.value)) {
        validApps.add({'name': entry.key, 'icon': entry.value});
      }
    }
    setState(() {
      filteredApps = validApps;
    });
  }

  void handleSearch(String query) async {
    searchQuery = query;
    if (query.isEmpty) {
      filterValidAssets();
    } else {
      List<Map<String, String>> validApps = [];
      for (var entry in _assets.entries) {
        if (entry.key.contains(query.toLowerCase()) &&
            await isValidAsset(entry.value)) {
          validApps.add({'name': entry.key, 'icon': entry.value});
        }
      }
      setState(() {
        filteredApps = validApps;
      });
    }
  }

  Future<void> loadFavourites() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    List<String>? favs = pref.getStringList('fav');
    if (favs != null) {
      if (favs.length > 3) {
        favs.removeAt(0);
      }
      setState(() {
        favourites = favs;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select your App'),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.only(left: 10, right: 10),
        child: Column(
          children: [
            // Search Bar Section
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 10.0,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Theme.of(context).cardColor),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, size: 20, color: Colors.grey),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        onChanged: handleSearch,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'sans-serif',
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Search for saved passwords...',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // List of Apps below the search bar
            Expanded(
              child: ListView.builder(
                itemCount: filteredApps.length,
                itemBuilder: (context, index) {
                  final app = filteredApps[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 5),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                      leading: Image.asset(app['icon']!, width: 50, height: 50),
                      title: Text(
                        app['name']!,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Roboto',
                          color: Colors.white,
                        ),
                      ),
                      subtitle: Text(
                        'Tap to select',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      onTap: () {
                        Navigator.pop(context, app['name']);
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
