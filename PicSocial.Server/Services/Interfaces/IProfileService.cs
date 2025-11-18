using PicSocial.Server.DTOs;

namespace PicSocial.Server.Services.Interfaces
{
    public interface IProfileService
    {
        Task<UserProfileDto?> GetProfileByIdAsync(string currentUserId, string targetUserId);
        Task<UserProfileDto?> GetMyProfileAsync(string currentUserId);
        Task<bool> UpdateMyProfileAsync(string currentUserId, UpdateProfileDto updateProfileDto);
    }
}
