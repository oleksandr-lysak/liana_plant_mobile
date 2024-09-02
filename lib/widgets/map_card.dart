import 'package:flutter/material.dart';
import 'package:liana_plant/constants/app_constants.dart';
import 'package:liana_plant/constants/styles.dart';
import 'package:liana_plant/models/map_marker_model.dart';

class MapCard extends StatelessWidget {
  const MapCard({super.key, required this.item});
  final MapMarker? item;
  @override
  Widget build(BuildContext context) {
    String description = item?.description ?? '';
    String photo = AppConstants.publicServerUrl + item!.image! ?? '';
    if (description.length > 200) {
      description = '${description.substring(0, 200)}...';
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
        color: Styles.backgroundColor,
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
                      itemCount: (item?.rating?.toInt() ?? 0),
                      itemBuilder: (BuildContext context, int index) {
                        return const Icon(
                          Icons.star,
                          color: Styles.primaryColor,
                        );
                      },
                    ),
                  ),
                  //Text(item!.rating!.toStringAsFixed(2)),
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item?.title ?? '',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Styles.titleColor,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          address ?? '',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Styles.subtitleColor,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          description,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Styles.descriptionColor,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          item!.phone.toString(),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Styles.primaryColor,
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
                    child: Image.network(photo, fit: BoxFit.cover, errorBuilder:
                        (BuildContext context, Object error,
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
