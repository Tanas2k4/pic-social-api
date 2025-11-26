using PicSocial.Server.DTOs.ProfilesDto;
using PicSocial.Server.Shared;

namespace PicSocial.Server.Services.Interfaces
{
    public interface IProfileService
    {
        Task<Results<ProfileUserDto>> GetProfileByIdAsync(string currentUserId, string targetUserId);
        Task<Results<ProfileUserDto>> GetMyProfileAsync(string currentUserId);
        Task<Results<ProfileUserDto>> UpdateMyProfileAsync(string currentUserId, ProfileUpdateDto updateProfileDto);
    }
}
