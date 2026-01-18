# PicSocial API Backend-Server


[![.NET 9.0](https://img.shields.io/badge/.NET-9.0-512BD4?logo=.net&logoColor=white)](https://dotnet.microsoft.com/)
[![ASP.NET Core](https://img.shields.io/badge/ASP.NET_Core-512BD4?logo=dotnet&logoColor=white)](https://dotnet.microsoft.com/apps/aspnet)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
  
API backend for a social web(app) about photos, life or many other things.

I only build API and you can visit **[picsocial-api-docs](https://tanas2k4.github.io/picsocial-api-docs)**, but it only static docs.

##Tech Stack

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
- Copy `appsettings.Example.json` to `appsettings.Development.json`
- Update the database connection string and JWT settings
Apply database migrations
```bash
dotnet ef migration add FirstInitial
dotnet ef database update
```
Run the application
```bash
dotnet run
```
The API will be available at: https://localhost:5001

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
