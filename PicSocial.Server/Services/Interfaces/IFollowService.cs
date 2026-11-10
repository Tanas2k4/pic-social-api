using PicSocial.Server.DTOs.FollowsDto;
using PicSocial.Server.Shared;

namespace PicSocial.Server.Services.Interfaces
{
    public interface IFollowService
    {
        Task<bool> IsFollowingAsync(string currentUserId, string targetUserId);
        Task<Result> FollowUserAsync(string currentUserId, FollowDto followDto);
        Task<Result> UnfollowUserAsync(string currentUserId, string targetUserId);
        Task<List<FollowerItemDto>> GetFollowerAsync(string userId);
        Task<List<FollowingItemDto>> GetFollowingAsync(string userId);
    }
}
