import 'package:flutter/material.dart';
import 'package:liana_plant/models/map_marker_model.dart';

class MapCard extends StatelessWidget {
  const MapCard({super.key, required this.item});
  final MapMarker? item;
  @override
  Widget build(BuildContext context) {
    String description = item?.description ?? '';
    if (description.length > 100) {
      description = '${description.substring(0, 100)}...';
    }
    String address = item?.address ?? '';
    if (address.length > 27) {
      address = '${address.substring(0, 27)}..';
    }
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        color: const Color.fromARGB(255, 30, 29, 29),
        child: Row(
          children: [
            const SizedBox(width: 5),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      scrollDirection: Axis.horizontal,
                      itemCount: item?.rating,
                      itemBuilder: (BuildContext context, int index) {
                        return const Icon(
                          Icons.star,
                          color: Colors.orange,
                        );
                      },
                    ),
                  ),

                  //Text(item!.rating.toString()),
                  Expanded(
                    flex: 6,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item?.title ?? '',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          address ?? '',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.blueGrey,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          description,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          item!.phone.toString(),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 5),

            Stack(
              children: [
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(item?.image ?? '', fit: BoxFit.cover,
                        errorBuilder: (BuildContext context, Object error,
                            StackTrace? stackTrace) {
                      return const Icon(
                        Icons.error,
                        color: Colors.red,
                      );
                    }),
                  ),
                )),
              ],
            ),

            //const SizedBox(width: 5),
          ],
        ),
      ),
    );
  }
}
