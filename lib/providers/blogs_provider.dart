import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/blog.dart';
import '../enums/story_type_enum.dart'; // Import StoryType

final blogsProvider =
    StateNotifierProvider<BlogsNotifier, AsyncValue<List<Blog>>>((ref) {
  return BlogsNotifier(ref);
});

final selectedBlogProvider = StateProvider<Blog?>((ref) => null);

// Provider for fetching a specific blog by ID
final blogDetailProvider =
    FutureProvider.family<Blog?, String>((ref, id) async {
  return ref.read(blogsProvider.notifier).fetchBlogDetails(id);
});

// MOCK DATA FOR PROTOTYPE
final List<Blog> mockBlogs = [
  Blog(
    id: '1',
    titleEn: 'The Forgotten Fortress: A Brief History of Kalemegdan',
    titleSr: 'Zaboravljena tvrđava: Kratka istorija Kalemegdana',
    storyType: StoryType.LANDMARK_SPOTLIGHT, // Added storyType
    contentEn: {
      'document': [
        {
          'type': 'heading',
          'level': 2,
          'children': [
            {'text': 'The Forgotten Fortress'}
          ]
        },
        {
          'type': 'paragraph',
          'children': [
            {
              'text':
                  'Kalemegdan has stood watch over Belgrade for centuries. From Roman outpost to Ottoman stronghold, its stones have witnessed countless stories.'
            }
          ]
        },
        {
          'type': 'image',
          'src':
              'https://upload.wikimedia.org/wikipedia/commons/6/6e/Kalemegdan_Fortress_Belgrade.jpg',
          'caption': 'Kalemegdan Fortress, 1900s'
        },
        {
          'type': 'paragraph',
          'children': [
            {
              'text':
                  'Today, it is a park, a museum, and a symbol of resilience.'
            }
          ]
        },
      ]
    },
    contentSr: {
      'document': [
        {
          'type': 'heading',
          'level': 2,
          'children': [
            {'text': 'Zaboravljena tvrđava'}
          ]
        },
        {
          'type': 'paragraph',
          'children': [
            {
              'text':
                  'Kalemegdan stražari nad Beogradom vekovima. Od rimskog utvrđenja do osmanske tvrđave, njegovo kamenje pamti bezbroj priča.'
            }
          ]
        },
        {
          'type': 'image',
          'src':
              'https://lh3.googleusercontent.com/gps-cs-s/AC9h4nogBZtNuAhGT4y1nC0IQBRVuAIA007YHirhDMhURUwhcfxsjFK4Tqge5P6n92HpM-Hoi54pf_NNwG2OiNU4m-ZafM3nioTmBq6xHyQxPKXrhLEHIe9zuQ69zGWCIEnwzDSwZGaC2g=s1360-w1360-h1020-rw',
          'caption': 'Tvrđava Kalemegdan, 1900-te'
        },
        {
          'type': 'paragraph',
          'children': [
            {'text': 'Danas je to park, muzej i simbol izdržljivosti.'}
          ]
        },
      ]
    },
    imageUrl:
        'https://lh3.googleusercontent.com/gps-cs-s/AC9h4nogBZtNuAhGT4y1nC0IQBRVuAIA007YHirhDMhURUwhcfxsjFK4Tqge5P6n92HpM-Hoi54pf_NNwG2OiNU4m-ZafM3nioTmBq6xHyQxPKXrhLEHIe9zuQ69zGWCIEnwzDSwZGaC2g=s1360-w1360-h1020-rw',
    createdAt: DateTime(2023, 5, 1),
  ),
  Blog(
    id: '2',
    titleEn: 'Interview: Memories of the 1996-97 Protests',
    titleSr: 'Intervju: Sećanja na proteste 1996-97',
    storyType: StoryType.INTERVIEW, // Added storyType
    contentEn: {
      'document': [
        {
          'type': 'heading',
          'level': 2,
          'children': [
            {'text': 'Interview with Ana Petrović'}
          ]
        },
        {
          'type': 'paragraph',
          'children': [
            {
              'text':
                  'Ana Petrović was a student during the winter protests. She recalls the energy, the fear, and the hope that filled the streets.'
            }
          ]
        },
        {
          'type': 'quote',
          'children': [
            {
              'text':
                  '“We walked for hours, singing and shouting. It felt like the whole city was awake.”'
            }
          ]
        },
        {
          'type': 'paragraph',
          'children': [
            {'text': 'The protests changed her life—and the city.'}
          ]
        },
      ]
    },
    contentSr: {
      'document': [
        {
          'type': 'heading',
          'level': 2,
          'children': [
            {'text': 'Intervju sa Anom Petrović'}
          ]
        },
        {
          'type': 'paragraph',
          'children': [
            {
              'text':
                  'Ana Petrović je bila studentkinja tokom zimskih protesta. Seća se energije, straha i nade koji su ispunjavali ulice.'
            }
          ]
        },
        {
          'type': 'quote',
          'children': [
            {
              'text':
                  '„Šetali smo satima, pevali i vikali. Izgledalo je kao da je ceo grad budan.“'
            }
          ]
        },
        {
          'type': 'paragraph',
          'children': [
            {'text': 'Protesti su joj promenili život—i grad.'}
          ]
        },
      ]
    },
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/2/2d/Belgrade_Protests_1996-97.jpg',
    createdAt: DateTime(2023, 6, 15),
  ),
  Blog(
    id: '3',
    titleEn: 'Belgrade’s Lost Cinemas',
    titleSr: 'Izgubljene bioskopske sale Beograda',
    storyType: StoryType.VENUE_SPOTLIGHT, // Added storyType
    contentEn: {
      'document': [
        {
          'type': 'heading',
          'level': 2,
          'children': [
            {'text': 'Belgrade’s Lost Cinemas'}
          ]
        },
        {
          'type': 'paragraph',
          'children': [
            {
              'text':
                  'Once, every neighborhood had its own cinema. Today, only a few remain.'
            }
          ]
        },
        {
          'type': 'image',
          'src':
              'https://upload.wikimedia.org/wikipedia/commons/3/3d/Beograd_bioskop.jpg',
          'caption': 'Old cinema, Belgrade'
        },
        {
          'type': 'paragraph',
          'children': [
            {
              'text':
                  'This article explores the stories behind the city’s most beloved movie theaters.'
            }
          ]
        },
      ]
    },
    contentSr: {
      'document': [
        {
          'type': 'heading',
          'level': 2,
          'children': [
            {'text': 'Izgubljene bioskopske sale'}
          ]
        },
        {
          'type': 'paragraph',
          'children': [
            {
              'text':
                  'Nekada je svaki kraj imao svoj bioskop. Danas ih je ostalo samo nekoliko.'
            }
          ]
        },
        {
          'type': 'image',
          'src':
              'https://lh3.googleusercontent.com/gps-cs-s/AC9h4nogBZtNuAhGT4y1nC0IQBRVuAIA007YHirhDMhURUwhcfxsjFK4Tqge5P6n92HpM-Hoi54pf_NNwG2OiNU4m-ZafM3nioTmBq6xHyQxPKXrhLEHIe9zuQ69zGWCIEnwzDSwZGaC2g=s1360-w1360-h1020-rw',
          'caption': 'Stari bioskop, Beograd'
        },
        {
          'type': 'paragraph',
          'children': [
            {
              'text':
                  'Ovaj tekst istražuje priče iza najvoljenijih gradskih bioskopa.'
            }
          ]
        },
      ]
    },
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/3/3d/Beograd_bioskop.jpg',
    createdAt: DateTime(2023, 7, 10),
  ),
  Blog(
    id: '4',
    titleEn: 'Sounds and Stories: Multimedia in Belgrade',
    titleSr: 'Zvuci i priče: Multimedija u Beogradu',
    storyType: StoryType.TOUR_PROMOTION, // Added storyType
    contentEn: {
      'document': [
        {
          'type': 'heading',
          'level': 2,
          'children': [
            {'text': 'Sounds and Stories'}
          ]
        },
        {
          'type': 'paragraph',
          'children': [
            {'text': 'Experience Belgrade through sound, video, and place.'}
          ]
        },
        // Video block
        {
          'type': 'component-block',
          'component': 'video',
          'props': {
            'videoUrl': 'https://samplelib.com/mp4/sample-720p.mp4',
            'autoplay': false,
            'loop': false
          }
        },
        // Audio block
        {
          'type': 'component-block',
          'component': 'audio',
          'props': {
            'audioUrl':
                'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3'
          }
        },
        // Inline location card block (using '11' for "Narodni muzej" from sample API)
        {
          'type': 'component-block',
          'component': 'location_card',
          'props': {'locationId': '11'}
        },
        {
          'type': 'paragraph',
          'children': [
            {
              'text':
                  'Each element above is interactive and demonstrates the power of multimedia storytelling.'
            }
          ]
        },
      ]
    },
    contentSr: {
      'document': [
        {
          'type': 'heading',
          'level': 2,
          'children': [
            {'text': 'Zvuci i priče'}
          ]
        },
        {
          'type': 'paragraph',
          'children': [
            {'text': 'Doživite Beograd kroz zvuk, video i mesto.'}
          ]
        },
        {
          'type': 'component-block',
          'component': 'video',
          'props': {
            'videoUrl': 'https://samplelib.com/mp4/sample-720p.mp4',
            'autoplay': false,
            'loop': false
          }
        },
        {
          'type': 'component-block',
          'component': 'audio',
          'props': {
            'audioUrl':
                'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3'
          }
        },
        // Same change for the Serbian content
        {
          'type': 'component-block',
          'component': 'location_card',
          'props': {'locationId': '11'}
        },
        {
          'type': 'paragraph',
          'children': [
            {
              'text':
                  'Svaki element iznad je interaktivan i pokazuje moć multimedijalnog pripovedanja.'
            }
          ]
        },
      ]
    },
    imageUrl: 'https://images.unsplash.com/photo-1506744038136-46273834b3fb',
    createdAt: DateTime(2024, 2, 20),
  ),
  // Add a general story for variety
  Blog(
    id: '5',
    titleEn: 'A Walk Through Skadarlija',
    titleSr: 'Šetnja Skadarlijom',
    storyType: StoryType.GENERAL_STORY, // Added storyType
    contentEn: {
      'document': [
        {
          'type': 'heading',
          'level': 2,
          'children': [
            {'text': 'A Walk Through Skadarlija'}
          ]
        },
        {
          'type': 'paragraph',
          'children': [
            {
              'text':
                  'Skadarlija, Belgrade\'s bohemian quarter, offers a unique glimpse into the city\'s artistic past. Cobblestone streets, traditional kafanas, and live music create an unforgettable atmosphere.'
            }
          ]
        },
        {
          'type': 'image',
          'src':
              'https://images.unsplash.com/photo-1600007283621-5f7f6a5a5f3b', // Example image
          'caption': 'Skadarlija Street'
        }
      ]
    },
    contentSr: {
      'document': [
        {
          'type': 'heading',
          'level': 2,
          'children': [
            {'text': 'Šetnja Skadarlijom'}
          ]
        },
        {
          'type': 'paragraph',
          'children': [
            {
              'text':
                  'Skadarlija, boemska četvrt Beograda, pruža jedinstven uvid u umetničku prošlost grada. Kaldrmisane ulice, tradicionalne kafane i živa muzika stvaraju nezaboravnu atmosferu.'
            }
          ]
        },
        {
          'type': 'image',
          'src':
              'https://images.unsplash.com/photo-1600007283621-5f7f6a5a5f3b', // Example image
          'caption': 'Skadarska ulica'
        }
      ]
    },
    imageUrl: 'https://images.unsplash.com/photo-1600007283621-5f7f6a5a5f3b',
    createdAt: DateTime(2024, 3, 10),
  ),
];

class BlogsNotifier extends StateNotifier<AsyncValue<List<Blog>>> {
  final Ref ref;

  BlogsNotifier(this.ref) : super(const AsyncValue.loading()) {
    fetchBlogs();
  }

  Future<void> fetchBlogs() async {
    // Use mock data for prototype
    await Future.delayed(const Duration(milliseconds: 500));
    state = AsyncValue.data(mockBlogs);
  }

  Future<Blog?> fetchBlogDetails(String id) async {
    // Use mock data for prototype
    await Future.delayed(const Duration(milliseconds: 200));
    for (final b in mockBlogs) {
      if (b.id == id) return b;
    }
    return null;
  }
}
