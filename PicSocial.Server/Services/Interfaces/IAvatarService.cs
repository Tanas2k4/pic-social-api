using PicSocial.Server.Shared;

namespace PicSocial.Server.Services.Interfaces
{
    public interface IAvatarService
    {
        Task<Result> UploadAvatarAsync(string currentUserId, IFormFile avatar);
        Task<Result> DeleteAvatarAsync(string currentUserId);
    }
}
