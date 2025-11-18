using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PicSocial.Server.Models;
using PicSocial.Server.Services.Interfaces;

namespace PicSocial.Server.Services.Implementations
{

    public class FollowService: IFollowService
    {
        private readonly ApplicationDbContext _context;

        public FollowService(ApplicationDbContext context)
        {
            _context = context;

        }

        // Kiểm tra xem currentUserId có đang follow targetUserId hay không
        public async Task<bool> IsFollowingAsync(string currentUserId, string targetUserId )
        {
            bool isFollowing = await _context.Follows
                .AnyAsync(f => f.FollowerId == currentUserId && f.FollowedId == targetUserId);
            return isFollowing;
        }
    }
}
