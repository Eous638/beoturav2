import 'package:flutter/material.dart';

class AssociatedToursSection extends StatelessWidget {
  final String venueName;
  final String tourType; // e.g., "Museum Tours", "Pub Crawls"

  const AssociatedToursSection({
    super.key,
    required this.venueName,
    required this.tourType,
  });

  // Placeholder data for tours - replace with actual data model and fetching
  final List<Map<String, String>> _tours = const [
    {
      'title': 'Historical Highlights Tour',
      'imageUrl': 'https://picsum.photos/seed/tour1/600/400',
      'duration': '2 hours',
      'rating': '4.8',
    },
    {
      'title': 'After Dark: Spooky Legends',
      'imageUrl': 'https://picsum.photos/seed/tour2/600/400',
      'duration': '1.5 hours',
      'rating': '4.5',
    },
    {
      'title': 'The Art & Architecture Walk',
      'imageUrl': 'https://picsum.photos/seed/tour3/600/400',
      'duration': '2.5 hours',
      'rating': '4.9',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
          child: Text(
            '$tourType at $venueName',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(color: Colors.white70, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 320, // Adjusted height from 300 to 320
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            itemCount: _tours.length,
            itemBuilder: (context, index) {
              final tour = _tours[index];
              return _buildTourCard(context, tour);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTourCard(BuildContext context, Map<String, String> tour) {
    return SizedBox(
      width: 280, // Width of each card
      child: Card(
        color: Colors.grey[850], // Slightly darker card background
        clipBehavior: Clip.antiAlias, // Ensures the image corners are rounded
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        elevation: 4,
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: InkWell(
          onTap: () {
            // TODO: Navigate to full tour details page or show modal
            print('Tapped on tour: ${tour['title']}');
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(
                tour['imageUrl']!,
                height: 160, // Height for the image
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 160,
                  color: Colors.grey[700],
                  child: const Center(
                      child: Icon(Icons.broken_image,
                          color: Colors.white54, size: 40)),
                ),
                loadingBuilder: (BuildContext context, Widget child,
                    ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 160,
                    color: Colors.grey[800],
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(Colors.white70),
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tour['title']!,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.timer_outlined,
                            color: Colors.white70, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          tour['duration']!,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.white70),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.star_border, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          tour['rating']!,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          // TODO: Navigate to tour booking or details
                          print('Learn more about: ${tour['title']}');
                        },
                        child: const Text('Learn More',
                            style: TextStyle(color: Colors.amberAccent)),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
