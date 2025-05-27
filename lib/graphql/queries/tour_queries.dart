class TourQueries {
  // Query to get all tours with basic information (for listings)
  static String getAllToursBasic = r'''
    query GetAllToursBasic {
      tours {
        id
        title_en
        title_sr
        description_outdated_en
        description_outdated_sr
        image {
          image {
            url
          }
        }
        headerImageUrl
        createdAt
        order
      }
    }
  ''';

  // Complete query to get a tour with all page and location details
  // Updated to include both content and description fields for locations
  static String getTourComplete = r'''
    query GetTourComplete($id: ID!) {
      tour(where: {id: $id}) {
        id
        title_en
        title_sr
        description_outdated_en
        description_outdated_sr
        image {
          image {
            url
          }
        }
        headerImageUrl
        frontPageContent_en {
          document
        }
        frontPageContent_sr {
          document
        }
        createdAt
        pages {
          id
          type
          order
          
          location {
            id
            title_en
            title_sr
            description_outdated_en
            description_outdated_sr
            content_en {
              document
            }
            content_sr {
              document
            }
            image {
              image {
                url
              }
            }
            headerImageUrl
            coordinates
          }
          content_en {
            document
          }
          content_sr {
            document
          }
          createdAt
        }
      }
    }
  ''';
}
