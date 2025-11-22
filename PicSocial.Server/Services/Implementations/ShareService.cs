using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using PicSocial.Server.DTOs;
using PicSocial.Server.Models;
using PicSocial.Server.Models.Entities;
using PicSocial.Server.Services.Interfaces;
using PicSocial.Server.Shared;

namespace PicSocial.Server.Services.Implementations
{
    public class ShareService : IShareService
    {
        private readonly ApplicationDbContext _context;
        private readonly UserManager<ApplicationUser> _userManager;
        public ShareService(ApplicationDbContext context, UserManager<ApplicationUser> userManager)
        {
            _context = context;
            _userManager = userManager;
        }

        //share a post
        public async Task<Result<ShareCreateDto>> SharePostAsync(Guid postId, string userId, ShareDto shareDto)
        {
            var user = await _context.Users.FindAsync(userId);
            if (user == null)
                return Result<ShareCreateDto>.NotFound("user not found");

            var post = await _context.Posts
                .Include(p => p.Photos)
                .Include(p => p.User)
                .FirstOrDefaultAsync(p => p.PostId == postId);
            if (post == null)
                return Result<ShareCreateDto>.NotFound("Post not found");

            var share = new Share
            {
                PostId = postId,
                UserId = userId,
                Caption = shareDto.Caption,
                SharePlatform = shareDto.SharePlatform ?? "Internal",
                CreatedDate = DateTimeOffset.Now
            };

            _context.Shares.Add(share);
            post.ShareCount++;

            await _context.SaveChangesAsync();

            return Result<ShareCreateDto>.Ok(new ShareCreateDto
            {
                Message = "Post shared successfully",
                Share = new ShareDetailDto
                {
                    PostId = postId,
                    ShareUserName = user.UserName,
                    Caption = share.Caption,
                    SharePlatform = share.SharePlatform,
                    Post = new
                    {
                        PostOwnerUserName = post.User.UserName,
                        Photos = post.Photos.Select(p => new
                        {
                            originalFileUrl = p.OriginalFileUrl
                        })
                    },
                    CreatedDate = share.CreatedDate,
                }
            });
        }

        //delete share post
        public async Task<Result> DeleteSharePostAsync(Guid postId, Guid shareId, string currentUserId)
        {
            var currentUser = await _userManager.FindByIdAsync(currentUserId);
            if (currentUser == null)
                return Result.NotFound("Current user not found");
            
            var share = await _context.Shares
                .FirstOrDefaultAsync(s => s.ShareId == shareId && s.PostId == postId);
            if (share == null)
                return Result.NotFound("Share not found");           

            var post = await _context.Posts
                .FirstOrDefaultAsync(p => p.PostId == postId);
            if (post == null)
                return Result.NotFound("Post not found");

            var isAdmin = await _userManager.IsInRoleAsync(currentUser, "Admin");
            if (share.UserId != currentUserId && !isAdmin)
                return Result.Unauthorized("Unauthorized to delete this share");
           
            _context.Shares.Remove(share);
            
            post.ShareCount--;
            await _context.SaveChangesAsync();
            return Result.Ok("Share deleted successfully");
        }
    }
}
