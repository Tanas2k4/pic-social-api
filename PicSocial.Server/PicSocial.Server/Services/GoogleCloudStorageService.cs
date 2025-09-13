using Google.Cloud.Storage.V1;

namespace PicSocial.Server.Services
{
    public class GoogleCloudStorageService
    {
        private readonly StorageClient _storageClient;
        private readonly string _bucketName;

        public GoogleCloudStorageService(IConfiguration configuration)
        {
            var bucket = configuration["GoogleCloudStorage:BucketName"];
            var credentialsPath = configuration["GoogleCloudStorage:CredentialsPath"];

            _storageClient = StorageClient.Create(
                Google.Apis.Auth.OAuth2.GoogleCredential.FromFile(credentialsPath)
            );
            _bucketName = bucket!;
        }

        // Upload file to Google Cloud Storage
        public async Task<string> UploadFileAsync(Stream fileStream, string fileName, string contentType)
        {
            await _storageClient.UploadObjectAsync(_bucketName, fileName, contentType, fileStream);

            //Trả về URL của file đã upload
            return $"https://storage.googleapis.com/{_bucketName}/{fileName}";
        }

        // Delete file from Google Cloud Storage
        public async Task<bool> DeleteFileAsync(string fileName)
        {
            try
            {
                await _storageClient.DeleteObjectAsync(_bucketName, fileName);
                return true;
            }
            catch (Google.GoogleApiException e) when (e.Error.Code == 404)
            {
                return false; // File not found
            }
        }
    }
}