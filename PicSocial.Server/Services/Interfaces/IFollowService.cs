using Microsoft.AspNetCore.Mvc;
using PicSocial.Server.DTOs;

namespace PicSocial.Server.Services.Interfaces
{
    public interface IFollowService
    {
        Task<bool> IsFollowingAsync(string currentUserId, string targetUserId);
        Task<FollowResult> FollowUserAsync(string currentUserId, FollowDto followDto);
        Task<bool> UnfollowUserAsync(string currentUserId, string targetUserId);
        Task<IActionResult> GetFollowerAsync(string userId);
        Task<IActionResult> GetFollowingAsync(string userId);
    }
}
