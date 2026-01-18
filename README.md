# PicSocial API Backend-Server


[![.NET 9.0](https://img.shields.io/badge/.NET-9.0-512BD4?logo=.net&logoColor=white)](https://dotnet.microsoft.com/)
[![ASP.NET Core](https://img.shields.io/badge/ASP.NET_Core-9.0-512BD4?logo=dotnet&logoColor=white)](https://dotnet.microsoft.com/apps/aspnet)
[![SQL Server](https://img.shields.io/badge/SQL_Server-CC2927?logo=microsoft-sql-server&logoColor=white)](https://www.microsoft.com/en-us/sql-server)
[![JWT](https://img.shields.io/badge/JWT-black?logo=json-web-tokens&logoColor=white)](https://jwt.io)
[![Google Cloud Storage](https://img.shields.io/badge/Google_Cloud_Storage-4285F4?logo=google-cloud&logoColor=white)](https://cloud.google.com/storage)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
  
API backend for a social web(app) about photos, life or many other things.

I only build API and you can visit **[picsocial-api-docs](https://tanas2k4.github.io/picsocial-api-docs)**, but it only static docs.

## Tech Stack

- **ASP.NET Core (Web API)**
- **EF Core**
- **SQL Server** 
- **JWT Authentication**
- **Google Cloud Storage**

## Prerequisites

Make you sure have the following installed:
- **[.NET SDK 9.0+](https://dotnet.microsoft.com/en-us/download/dotnet/9.0)**
- SQL Server (or compatible database)
- Git

 ## Setup & Run Locally

 Clone the repository
```bash
git clone https://github.com/Tanas2k4/PicSocial.Server.git
```
Navigate to the project
```bash
cd PicSocial.Server
```
Configure environment
- You can config at `appsettings.Development.json` or `appsettings.json` if you have
- Update the database connection string and JWT settings
## Google Cloud Storage (GCS) Configuration
This project uses **Google Cloud Storage** to store uploaded media files (images, videos, documents, etc.).

**Each developer must create and use their own bucket** during local development to prevent conflicts and ensure data isolation.

## Prerequisites

- A Google Cloud Platform (GCP) account
- A GCP project with **billing enabled**
- Permissions to create buckets and service accounts (usually Owner or Editor role)

## Step 1: Create a Google Cloud Storage Bucket

1. Go to the [Google Cloud Console](https://console.cloud.google.com/)
2. Select or create a new project (recommended: use a personal or dev-specific project)
3. Navigate to **Cloud Storage → Buckets**
4. Click **Create bucket**
5. Recommended settings for development environments:

   | Setting                | Recommended Value                        | Reason                                                                 |
   |------------------------|------------------------------------------|------------------------------------------------------------------------|
   | Name                   | `yourname-project-media-dev`             | Must be **globally unique**; include personal/project prefix           |
   | Location type          | **Region**                               | Lower cost and latency compared to multi-region                        |
   | Location               | Choose closest region (e.g., `asia-southeast1` - Singapore) | Best latency for developers in Vietnam / Southeast Asia                |
   | Default storage class  | **Standard**                             | Suitable for frequent access in development                            |
   | Access control         | **Uniform**                              | Simpler and more secure (Google's recommendation)                      |
   | Protection tools       | Do **not** enable Object Versioning      | Avoid unnecessary storage costs in dev                                 |

6. Click **Create** → Record the **bucket name** (e.g., `tan2883-media-dev-2026`)

## Step 2: Create a Service Account and Key

1. Go to **IAM & Admin → Service Accounts**
2. Click **+ Create Service Account**
3. Fill in details:

   - Service account name: `media-upload-dev-[your-name]`
   - Service account ID: auto-generated
   - Description: "Service account for media uploads in development"

4. **Grant this service account access to project** → Assign role:

   - **Storage Object Admin** (`roles/storage.objectAdmin`)  
     → Allows full read/write/delete access to objects in the bucket (suitable for dev)

   *Note: In production, use narrower roles like `Storage Object Creator` + `Storage Object Viewer`*

5. Skip **Grant users access to this service account** (not needed)
6. After creation → Click **Keys → Add Key → Create new key → JSON**
7. The JSON key file will download automatically → Save it securely (e.g., `gcp-media-dev-key.json`)
8. **Never commit this file to Git!**

## Step 3: Configure the Application

### Option 1: Use JSON Key File (Recommended for Local Development)

Update **`appsettings.Development.json`** (or `appsettings.json` depending on your environment):

```json
{
  "GoogleCloudStorage": {
    "BucketName": "tan2883-media-dev-2026",
    "ProjectId": "your-project-id-123456",
    "CredentialsPath": "C:\\Users\\YourName\\gcp-media-dev-key.json"
    // or "~/gcp-media-dev-key.json" on macOS/Linux
  }
}
```
Apply database migrations
```bash
dotnet ef migration add FirstInitial
dotnet ef database update
```
Run the application
```bash
dotnet run
```
The API will be available at: https://localhost:5187

## Authentication

Authentication is handled using JWT Bearer Tokens.
Include the token in the `Authorization` header:
```bash
Authorization: Bearer <your_token>
```
## API Features

- User authentication and authorization
- Upload and manage posts
- Metadata and XMP metadata processing for media files
- Secure RESTful endpoints
You can see all details features at **[picsocial-api-docs](https://tanas2k4.github.io/picsocial-api-docs)**
## Testing

You can test the API using:
- Swagger UI (enabled in Development)
- Postman or Insomnia
Swagger endpoint:
```bash
/swagger
```
## Environment Variables

Example configuration:
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=<YOUR-SERVER-NAME>;Database=PicSocialDb;Trusted_Connection=True;TrustServerCertificate=True"
  },
  "Jwt": {
    "Key": "your-secret-key",
    "Issuer": "PicSocial",
    "Audience": "PicSocialUsers"
  }
}
```
## License
This project was built by **[Trần Tấn](https://github.com/Tanas2k4)**.
