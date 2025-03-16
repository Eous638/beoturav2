class TourQueries {
  // Query to get all tours
  static String getAllTours = r'''
    query GetAllTours {
      tours {
        id
        title_en
        title_sr
        frontPageContent_en {
          document
        }
        frontPageContent_sr {
          document
        }
        description_outdated_en
        description_outdated_sr
        image {
          image {
            url
          }
        }
        headerImageUrl
        order
      }
    }
  ''';

  // Query to get a specific tour by ID
  static String getTourById = r'''
    query GetTourById($id: ID!) {
      tour(id: $id) {
        id
        title_en
        title_sr
        frontPageContent_en {
          document
        }
        frontPageContent_sr {
          document
        }
        description_outdated_en
        description_outdated_sr
        image {
          image {
            url
          }
        }
        headerImageUrl
        order
        locations {
          id
          name
          description
          latitude
          longitude
          image {
            image {
              url
            }
          }
          headerImageUrl
          order
        }
      }
    }
  ''';
}
