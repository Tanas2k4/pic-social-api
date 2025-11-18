using PicSocial.Server.DTOs;

namespace PicSocial.Server.Services.Interfaces
{
    public interface IProfileService
    {
        Task<UserProfileDto?> GetProfileAsync(string currentUserId, string targetUserId);
    }
}
