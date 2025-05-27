class BlogQueries {
  static String getBlogs = '''
    query GetBlogs {
      blogs {
        id
        title_en
        title_sr
        image {
          image {
            url
          }
        }
        createdAt
      }
    }
  ''';

  static String getBlogDetails = '''
    query GetBlogDetails(\$id: ID!) {
      blog(where: { id: \$id }) {
        id
        title_en
        title_sr
        content_en
        {document}
        content_sr
        {document}
        image {
          image {
            url
          }
        }
        createdAt
      }
    }
  ''';

  static String getImageById = '''
    query GetImageById(\$id: ID!) {
      image(where: {id: \$id}) {
        image {
          url
        }
      }
    }
  ''';
}
