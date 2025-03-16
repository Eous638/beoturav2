class LocationQueries {
  // Query to get all locations
  static String getAllLocations = r'''
    query GetAllLocations {
      locations {
        id
        title_en
        title_sr
        content_en{
        document}
        content_sr{
        document}
        description_outdated_en
        description_outdated_sr
        image {
          image {
            url
          }
        }
        headerImageUrl
        coordinates
        order
      }
    }
  ''';

  // Query to get a specific location by ID
  static String getLocationById = r'''
    query GetLocationById($id: ID!) {
      location(id: $id) {
        id
        title_en
        title_sr
        content_en{
        document}
        content_sr{
        document}
        description_outdated_en
        description_outdated_sr
        image {
          image {
            url
          }
        }
        headerImageUrl
        coordinates
        order
      }
    }
  ''';
}
