using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PicSocial.Server.DTOs;
using PicSocial.Server.Models;
using PicSocial.Server.Models.Entities;
using PicSocial.Server.Services.Interfaces;

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

        public async Task<FollowResult> FollowUserAsync(string currentUserId, FollowDto followDto)
        {
            var currentUser = await _userManager.FindByIdAsync(currentUserId);
            if (currentUser == null)
                return new FollowResult { Success = false, Message = "Current user not found" };

            if (currentUserId == followDto.Id)
                return new FollowResult { Success = false, Message = "You cannot follow yourself" };

            var userToFollow = await _userManager.FindByIdAsync(followDto.Id);
            if (userToFollow == null)
                return new FollowResult { Success = false, Message = "User not found" };

            var existingFollow = await _context.Follows
                .FirstOrDefaultAsync(f => f.FollowerId == currentUserId && f.FollowedId == followDto.Id);

            if (existingFollow != null)
                return new FollowResult { Success = false, Message = "You are already following this user" };

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

            return new FollowResult { Success = true, Message = "Followed successfully" };
        }


        // Unfollow user
        public async Task<bool> UnfollowUserAsync(string currentUserId, string targetUserId)
        {
            var currentUser = await _userManager.FindByIdAsync(currentUserId);
            if (currentUser == null)
                return false;

            var userToUnfollow = await _userManager.FindByIdAsync(targetUserId);
            if (userToUnfollow == null)
                return false;

            var existingFollow = await _context.Follows
                .FirstOrDefaultAsync(f => f.FollowerId == currentUserId && f.FollowedId == targetUserId);
            if (existingFollow == null)
                return false; // Chưa follow

            _context.Follows.Remove(existingFollow);
            currentUser.FollowingCount--;
            userToUnfollow.FollowersCount--;

            _context.Users.Update(currentUser);
            _context.Users.Update(userToUnfollow);

            await _context.SaveChangesAsync();
            return true;
        }

        //Xem danh sách người theo dõi
        public async Task<IActionResult> GetFollowerAsync(string userId)
        {
            var user = await _userManager.FindByIdAsync(userId);
            if (user == null)
                return new NotFoundObjectResult("User not found.");
            var followers = await _context.Follows
                .Where(f => f.FollowedId == userId)
                .Select(f => new
                {                 
                    FollowerUserName = f.Follower.UserName,
                    FollowerFirstName = f.Follower.FirstName,
                    FollowerAvatar = f.Follower.AvatarUrl
                })
                .ToListAsync();
            return new OkObjectResult(followers);
        }

        //Xem danh sách người mà họ đang theo dõi
        public async Task<IActionResult> GetFollowingAsync(string userId)
        {
            var user = await _userManager.FindByIdAsync(userId);
            if (user == null)
                return new NotFoundObjectResult("User not found.");
            var following = await _context.Follows
                .Where(f => f.FollowerId == userId)
                .Select(f => new
                {
                    FollowingUserName = f.Followed.UserName,
                    FollowingFirstName = f.Followed.FirstName,
                    FollowingAvatar = f.Followed.AvatarUrl
                })
                .ToListAsync();
            return new OkObjectResult(following);
        }
    }
}
