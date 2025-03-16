# Keystone API Documentation for Flutter Integration

## Overview

This document outlines the data models and structures used in the Keystone 6 backend API. Understanding these models is crucial for proper integration with your Flutter frontend application.

## Data Models

### User

User accounts with role-based access control.

| Field | Type | Description | Notes |
|-------|------|-------------|-------|
| name | String | User's full name | Required |
| email | String | User's email address | Required, Unique |
| password | String | User's password | Required, Hidden from API responses |
| role | Enum | User's role in the system | 'admin', 'editor', or 'blockade_editor' |
| managedBlockades | Relationship | Blockades this user can manage | Many-to-many relationship with Blockade |
| createdAt | Timestamp | When user was created | Auto-generated |
| posts | Relationship | Blog posts authored by this user | One-to-many relationship with Blog |

**Access Control:**
- Only admins can create/delete users
- Users can update their own information
- Admins can update any user's information
- Only authenticated users can query user data

### Tour

Tours or guided experiences within the application.

| Field | Type | Description | Notes |
|-------|------|-------------|-------|
| title_en | String | English title | Required |
| title_sr | String | Serbian title | Required |
| frontPageContent_en | Document | English rich text content | Supports formatting, links, layouts |
| frontPageContent_sr | Document | Serbian rich text content | Supports formatting, links, layouts |
| pages | Relationship | Pages belonging to this tour | One-to-many relationship with Page |
| displayLocation | Enum | Where this tour is displayed | 'tours', 'protest', or 'both' |
| isEvent | Boolean | Whether this is an event | Default: false |
| startTime | Timestamp | When event starts | Only relevant if isEvent is true |
| endTime | Timestamp | When event ends | Only relevant if isEvent is true |
| isFeatured | Boolean | Whether featured on home screen | Default: false |
| createdAt | Timestamp | When tour was created | Auto-generated |
| image | Relationship | Main image for this tour | One-to-one relationship with Image |
| headerImageUrl | String | External URL for header image | Alternative to uploading an image |
| description_outdated_en | String | Outdated description in English | Plain text, for legacy content |
| description_outdated_sr | String | Outdated description in Serbian | Plain text, for legacy content |
| order | Integer | Display order on tours page | Default: 0 |

### Location

Physical locations on the map.

| Field | Type | Description | Notes |
|-------|------|-------------|-------|
| title_en | String | English title | Required |
| title_sr | String | Serbian title | Required |
| coordinates | JSON | Geographical coordinates | Read-only in admin UI |
| displayLocation | Enum | Where this location is displayed | 'map', 'protest', or 'both' |
| visibility | Enum | How this location is displayed | 'independent', 'tour', or 'both' |
| description_outdated_en | String | Outdated description in English | Plain text, for legacy content |
| description_outdated_sr | String | Outdated description in Serbian | Plain text, for legacy content |
| createdAt | Timestamp | When location was created | Auto-generated |
| image | Relationship | Main image for this location | One-to-one relationship with Image |
| headerImageUrl | String | External URL for header image | Alternative to uploading an image |
| order | Integer | Display order on map | Default: 0 |

### Blog

Blog posts for news and updates.

| Field | Type | Description | Notes |
|-------|------|-------------|-------|
| title | String | Default title | Required |
| title_en | String | English title | Optional |
| title_sr | String | Serbian title | Optional |
| displayLocation | Enum | Where this blog is displayed | 'blog', 'protest', or 'both' |
| content | Document | Default rich text content | Supports formatting, links, layouts |
| content_en | Document | English rich text content | Supports formatting, links, layouts |
| content_sr | Document | Serbian rich text content | Supports formatting, links, layouts |
| author | Relationship | User who wrote this post | One-to-one relationship with User |
| createdAt | Timestamp | When post was created | Auto-generated |
| publishedAt | Timestamp | When post was published | Null if not published |
| isFeatured | Boolean | Whether featured on home screen | Default: false |

### Page

Individual pages within a tour.

| Field | Type | Description | Notes |
|-------|------|-------------|-------|
| tour | Relationship | Tour this page belongs to | One-to-one relationship with Tour |
| type | Enum | Type of page | 'content' or 'location' |
| location | Relationship | Associated location | One-to-one relationship with Location |
| content_en | Document | English rich text content | Supports formatting, links, layouts |
| content_sr | Document | Serbian rich text content | Supports formatting, links, layouts |
| createdAt | Timestamp | When page was created | Auto-generated |
| order | Integer | Display order within tour | Default: 0 |

### Blockade

Information about protest blockades.

| Field | Type | Description | Notes |
|-------|------|-------------|-------|
| institutionName | String | Default institution name | Required, Indexed |
| institutionName_en | String | English institution name | Optional |
| institutionName_sr | String | Serbian institution name | Optional |
| description | Document | Default rich text description | Supports formatting, links |
| description_en | Document | English rich text description | Supports formatting, links |
| description_sr | Document | Serbian rich text description | Supports formatting, links |
| image | Relationship | Main image for this blockade | One-to-one relationship with Image |
| supplies | Relationship | Associated supplies | One-to-many relationship with Supply |
| updates | Relationship | Associated updates | One-to-many relationship with Update |
| displayLocation | Enum | Where this blockade is displayed | 'blockade', 'protest', or 'both' |
| isActive | Boolean | Whether blockade is active | Default: true |
| editors | Relationship | Users who can edit this blockade | Many-to-many relationship with User |
| createdAt | Timestamp | When blockade was created | Auto-generated |

**Access Control:**
- Special access for blockade editors who can only manage their assigned blockades
- Users only see active blockades unless they have editor permissions

### Supply

Supply items needed for blockades.

| Field | Type | Description | Notes |
|-------|------|-------------|-------|
| title | String | Default title | Required |
| title_en | String | English title | Optional |
| title_sr | String | Serbian title | Optional |
| quantity | Integer | Amount needed | Required, Default: 1 |
| icon | String | Icon name for display | e.g., "food", "water", "tent" |
| blockade | Relationship | Associated blockade | One-to-one relationship with Blockade |
| createdAt | Timestamp | When supply was created | Auto-generated |

### Update

Updates about blockades or events.

| Field | Type | Description | Notes |
|-------|------|-------------|-------|
| title | String | Default title | Required |
| title_en | String | English title | Optional |
| title_sr | String | Serbian title | Optional |
| content | Document | Default rich text content | Supports formatting |
| content_en | Document | English rich text content | Supports formatting |
| content_sr | Document | Serbian rich text content | Supports formatting |
| emergencyLevel | Enum | Urgency level | 'low', 'medium', 'high', or 'critical' |
| postDate | Timestamp | When update was posted | Auto-generated |
| blockade | Relationship | Associated blockade | One-to-one relationship with Blockade |

### Image

Reusable images for content.

| Field | Type | Description | Notes |
|-------|------|-------------|-------|
| title | String | Default title | Required, Indexed |
| title_en | String | English title | Optional |
| title_sr | String | Serbian title | Optional |
| altText | String | Default alt text | Required for accessibility |
| altText_en | String | English alt text | Optional |
| altText_sr | String | Serbian alt text | Optional |
| image | Image | Actual image file | Stored in content_images storage |
| credit | String | Photographer or owner credit | Optional |
| createdAt | Timestamp | When image was created | Auto-generated |

## Key Implementation Considerations

### Internationalization
- Most content models support both English (`_en`) and Serbian (`_sr`) localization
- Frontend should handle language switching based on user preference
- Default language fields (without suffix) are being phased out in favor of localized fields
- Outdated description fields (`description_outdated_en` and `description_outdated_sr`) exist for legacy content on some models

### Content Transition Strategy
- The schema shows a transition from plain text descriptions to rich Document fields
- Outdated description fields are maintained for backward compatibility
- Frontend should prioritize the new Document fields but fall back to legacy fields when needed

### Access Control
- Content access is controlled by user roles:
  - `admin`: Full access to all content
  - `editor`: Can edit most content
  - `blockade_editor`: Limited to managing assigned blockades
- Frontend should handle permissions-based UI adjustments

### Content Structure
- Rich text is stored as Document fields with support for formatting, links, and layouts
- Document fields support component blocks for advanced content structuring
- Order fields are used throughout to maintain display sequence

### Image Handling
- Images can be uploaded directly or referenced via external URLs
- All images have associated metadata including title, alt text, and optional credit
- Images are stored in a dedicated storage area called `content_images`

### Relationships
- Backend uses relationships to maintain data integrity
- Many-to-many and one-to-many relationships are used where appropriate
- All relationships should be properly populated when querying data

## API Endpoints

While the schema doesn't explicitly define API endpoints, Keystone 6 automatically generates GraphQL API endpoints based on these models. Your Flutter frontend should implement GraphQL queries and mutations to interact with this data.

Example GraphQL queries are not provided in this documentation, but you should develop them based on the data models described above.