using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Identity;
using PicSocial.Server.DTOs.ProfilesDto;
using PicSocial.Server.Models;
using PicSocial.Server.Services.Interfaces;
using PicSocial.Server.Shared;

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
        //Xem profile của user khác 
        public async Task<Results<ProfileUserDto>> GetProfileByIdAsync(string currentUserId, string targetUserId)
        {
            var targetUser = await _userManager.FindByIdAsync(targetUserId);
            if (targetUser == null)
                return Results<ProfileUserDto>.NotFound("user not found");

            bool isFollowing = await _service.IsFollowingAsync(currentUserId, targetUserId);

            var dto = new ProfileUserDto
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

            return Results<ProfileUserDto>.Ok(dto);
        }

        //Xem profile của chính mình
        public async Task<Results<ProfileUserDto>> GetMyProfileAsync(string currentUserId)
        {
            var currentUser = await _userManager.FindByIdAsync(currentUserId);
            if (currentUser == null)
                return Results<ProfileUserDto>.NotFound("User not found");
            var dto = new ProfileUserDto
            {
                UserName = currentUser.UserName!,
                FirstName = currentUser.FirstName,
                Bio = currentUser.Bio,
                AvatarUrl = currentUser.AvatarUrl,
                CoverPhotoUrl = currentUser.CoverPhotoUrl,
                FollowersCount = currentUser.FollowersCount,
                FollowingCount = currentUser.FollowingCount,
                Location = currentUser.Location
            };
            return Results<ProfileUserDto>.Ok(dto);
        }

        //Cập nhật profile của chính mình
        public async Task<Results<ProfileUserDto>> UpdateMyProfileAsync(string currentUserId, ProfileUpdateDto updateProfileDto)
        {
            var currentUser = await _userManager.FindByIdAsync(currentUserId);
            if (currentUser == null)
                return Results<ProfileUserDto>.NotFound();
            
            if (!string.IsNullOrWhiteSpace(updateProfileDto.FirstName))
                currentUser.FirstName = updateProfileDto.FirstName;
  
            if (!string.IsNullOrWhiteSpace(updateProfileDto.Bio))
                currentUser.Bio = updateProfileDto.Bio;
  
            if (!string.IsNullOrWhiteSpace(updateProfileDto.Location))
                currentUser.Location = updateProfileDto.Location;
            var result = await _userManager.UpdateAsync(currentUser);
            
            return Results<ProfileUserDto>.Ok(new ProfileUserDto
            {
                UserName = currentUser.UserName!,
                FirstName = currentUser.FirstName,
                Bio = currentUser.Bio,
                AvatarUrl = currentUser.AvatarUrl,
                CoverPhotoUrl = currentUser.CoverPhotoUrl,
                FollowersCount = currentUser.FollowersCount,
                FollowingCount = currentUser.FollowingCount,
                Location = currentUser.Location
            });
        }
    }
}
