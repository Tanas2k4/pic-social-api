using Microsoft.AspNetCore.Identity;
using PicSocial.Server.DTOs;
using PicSocial.Server.Models;
using PicSocial.Server.Services.Interfaces;

namespace PicSocial.Server.Services.Implementations
{
    public class ProfileService : IProfileService
    {
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly IFollowService _service;
        public ProfileService(UserManager<ApplicationUser> userManager, IFollowService service)
        {
            _userManager = userManager;
            _service = service;
        }
        public async Task<UserProfileDto?> GetProfileAsync(string currentUserId, string targetUserId)
        {
            var targetUser = await _userManager.FindByIdAsync(targetUserId);
            if (targetUser == null)
                return null;

            bool isFollowing = await _service.IsFollowingAsync(currentUserId, targetUserId);

            var dto = new UserProfileDto
            {
                UserName = targetUser.UserName!,
                FirstName = targetUser.FirstName,
                Bio = targetUser.Bio,
                AvatarUrl = targetUser.AvatarUrl,
                CoverPhotoUrl = targetUser.CoverPhotoUrl,
                FollowersCount = targetUser.FollowersCount,
                FollowingCount = targetUser.FollowingCount
            };

            // Nếu đã follow thì trả thêm thông tin đặc biệt
            if (isFollowing)
            {
                dto.Location = targetUser.Location;
            }

            return dto;
        }
    }
}
