using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using PicSocial.Server.DTOs.FollowsDto;
using PicSocial.Server.Models;
using PicSocial.Server.Models.Entities;
using PicSocial.Server.Services.Interfaces;
using PicSocial.Server.Shared;
namespace PicSocial.Server.Services.Implementations
{

    public class FollowService : IFollowService
    {
        private readonly ApplicationDbContext _context;
        private readonly UserManager<ApplicationUser> _userManager;
        public FollowService(ApplicationDbContext context, UserManager<ApplicationUser> userManager)
        {
            _context = context;
            _userManager = userManager;
        }

        // Kiểm tra xem currentUserId có đang follow targetUserId hay không
        public async Task<bool> IsFollowingAsync(string currentUserId, string targetUserId)
        {
            bool isFollowing = await _context.Follows
                .AnyAsync(f => f.FollowerId == currentUserId && f.FollowedId == targetUserId);
            return isFollowing;
        }

        public async Task<Result> FollowUserAsync(string currentUserId, FollowDto followDto)
        {
            var currentUser = await _userManager.FindByIdAsync(currentUserId);
            if (currentUser == null)
                return Result.NotFound("Current user not found");
            if (currentUserId == followDto.Id)
                return Result.Bad("You cannot follow yourself");

            var userToFollow = await _userManager.FindByIdAsync(followDto.Id);
            if (userToFollow == null)
                return Result.NotFound("User not found");

            var existingFollow = await _context.Follows
                .FirstOrDefaultAsync(f => f.FollowerId == currentUserId && f.FollowedId == followDto.Id);

            if (existingFollow != null)
                return Result.Bad("You are already following this user");

            // Tạo follow mới
            var follow = new Follow
            {
                FollowerId = currentUserId,
                FollowedId = followDto.Id,
                CreatedDate = DateTimeOffset.Now
            };

            _context.Follows.Add(follow);

            currentUser.FollowingCount++;
            userToFollow.FollowersCount++;

            await _context.SaveChangesAsync();

            return Result.Ok("Followed successfully");
        }


        // Unfollow user
        public async Task<Result> UnfollowUserAsync(string currentUserId, string targetUserId)
        {
            var currentUser = await _userManager.FindByIdAsync(currentUserId);
            if (currentUser == null)
                return Result.Unauthorized();

            var userToUnfollow = await _userManager.FindByIdAsync(targetUserId);
            if (userToUnfollow == null)
                return Result.NotFound("User not found");

            var existingFollow = await _context.Follows
                .FirstOrDefaultAsync(f => f.FollowerId == currentUserId && f.FollowedId == targetUserId);
            if (existingFollow == null)
                return Result.Bad("you haven't followed this user before"); // Chưa follow

            _context.Follows.Remove(existingFollow);
            currentUser.FollowingCount--;
            userToUnfollow.FollowersCount--;

            _context.Users.Update(currentUser);
            _context.Users.Update(userToUnfollow);

            await _context.SaveChangesAsync();
            return Result.Ok("Successfully unfollowed the user.");
        }

        //Xem danh sách người theo dõi
        public async Task<List<FollowerItemDto>> GetFollowerAsync(string userId)
        {
            var followers = await _context.Follows
                .Where(f => f.FollowedId == userId)
                .Select(f => new FollowerItemDto
                {
                    FollowerUserName = f.Follower.UserName,
                    FollowerFirstName = f.Follower.FullName,
                    FollowerAvatar = f.Follower.AvatarUrl
                })
                .ToListAsync();
            return followers;
        }

        //Xem danh sách người mà họ đang theo dõi
        public async Task<List<FollowingItemDto>> GetFollowingAsync(string userId)
        {
            var following = await _context.Follows
                .Where(f => f.FollowerId == userId)
                .Select(f => new FollowingItemDto
                {
                    FollowingUserName = f.Followed.UserName,
                    FollowingFirstName = f.Followed.FullName,
                    FollowingAvatar = f.Followed.AvatarUrl
                })
                .ToListAsync();
            return following;
        }
    }
}
