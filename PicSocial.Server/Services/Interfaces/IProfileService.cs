using PicSocial.Server.DTOs;
using PicSocial.Server.Shared;
using System.Threading.Tasks;

namespace PicSocial.Server.Services.Interfaces
{
    public interface IProfileService
    {
        Task<Result<UserProfileDto>> GetProfileByIdAsync(string currentUserId, string targetUserId);
        Task<Result<UserProfileDto>> GetMyProfileAsync(string currentUserId);
        Task<Result<UserProfileDto>> UpdateMyProfileAsync(string currentUserId, UpdateProfileDto updateProfileDto);
    }
}
