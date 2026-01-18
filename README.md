# PicSocial API Backend-Server


[![.NET 9.0](https://img.shields.io/badge/.NET-9.0-512BD4?logo=.net&logoColor=white)](https://dotnet.microsoft.com/)
[![ASP.NET Core](https://img.shields.io/badge/ASP.NET_Core-512BD4?logo=dotnet&logoColor=white)](https://dotnet.microsoft.com/apps/aspnet)
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
## Cloud Storage Configuration (Google Cloud Storage)
This project uses Google Cloud Storage (GCS) for storing uploaded media files.
Each developer is required to create and use their own Google Cloud Storage bucket.
Prerequisites
- A Google Cloud Platform (GCP) account
- A GCP project with billing enabled
Create a Google Cloud Storage Bucket
1. Go to Google Cloud Console
2. Create a new project (or use an existing one)
3. Navigate to Cloud Storage → Buckets
4. Create a new bucket with the following recommendations:
  - Location type: Region
  - Storage class: Standard
  - Access control: Uniform
5. Note down the bucket name
Create a Service Account
1. Go to IAM & Admin → Service Accounts
2. Create a new service account
3. Grant the following role:
  - `Storage Object Admin`
4. Generate a JSON key file
5. Download and keep the key file secure
(Do NOT commit this file to the repository)
## Configure Application Settings
Update your appsettings.Development.json with your own bucket information:
```csharp
{
  "GoogleCloudStorage": {
    "BucketName": "your-bucket-name",
    "ProjectId": "your-gcp-project-id",
    "CredentialsPath": "path/to/your/service-account-key.json"
  }
}
```
Alternatively, you can set the credentials using an environment variable:
```bash
GOOGLE_APPLICATION_CREDENTIALS=path/to/your/service-account-key.json
```
## Notes
- Each developer should use their own GCS bucket
- Bucket credentials must never be shared or committed to source control
- The application assumes full access to the configured bucket for upload and retrieval operations
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
```csharp
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=.;Database=PicSocialDb;Trusted_Connection=True;"
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
