using PicSocial.Server.Shared;

namespace PicSocial.Server.Services.Interfaces
{
    public interface ICoverPhotoService
    {
        Task<Result> UploadPhotoCoverAsync(string currentUserId, IFormFile photoCover);
        Task<Result> DeletePhotoCoverAsync(string currentUserId);
    }
}
