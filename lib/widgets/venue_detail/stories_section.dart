import 'package:flutter/material.dart';

class StoriesSection extends StatelessWidget {
  final String venueName; // Example: To fetch stories related to this venue
  const StoriesSection({super.key, required this.venueName});

  // Placeholder data for stories - replace with actual data model and fetching
  final List<Map<String, String>> _stories = const [
    {
      'title': 'The Hidden History of Our Walls',
      'imageUrl': 'https://picsum.photos/seed/story1/600/400',
      'excerpt':
          'Discover the secrets embedded in the very structure of this iconic place.'
    },
    {
      'title': 'A Night to Remember: The Grand Opening Gala',
      'imageUrl': 'https://picsum.photos/seed/story2/600/400',
      'excerpt':
          'Relive the magic of the night that started it all, with exclusive photos and anecdotes.'
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
            'Stories about $venueName',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(color: Colors.white70, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 280, // Adjust height as needed for the cards
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            itemCount: _stories.length,
            itemBuilder: (context, index) {
              final story = _stories[index];
              return _buildStoryCard(context, story);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStoryCard(BuildContext context, Map<String, String> story) {
    return SizedBox(
      width: 250, // Width of each card
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
            // TODO: Navigate to full story page or show modal
            print('Tapped on story: ${story['title']}');
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(
                story['imageUrl']!,
                height: 150, // Height for the image
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 150,
                  color: Colors.grey[700],
                  child: const Center(
                      child: Icon(Icons.broken_image,
                          color: Colors.white54, size: 40)),
                ),
                loadingBuilder: (BuildContext context, Widget child,
                    ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 150,
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
                      story['title']!,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      story['excerpt']!,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.white70),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
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
