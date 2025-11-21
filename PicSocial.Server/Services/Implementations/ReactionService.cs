using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using PicSocial.Server.Models;
using PicSocial.Server.Models.Entities;
using PicSocial.Server.Services.Interfaces;
using PicSocial.Server.Shared;

namespace PicSocial.Server.Services.Implementations
{
    public class ReactionService : IReactionService
    {
        private readonly ApplicationDbContext _context;
        private readonly UserManager<ApplicationUser> _userManager;
        public ReactionService(ApplicationDbContext context, UserManager<ApplicationUser> userManager)
        {
            _context = context;
            _userManager = userManager;
        }

        // Reaction cho 1 bài viết
        public async Task<Result> ReactionPostAsync(string userId, Guid postId)
        {
            var post = await _context.Posts
                .FirstOrDefaultAsync(p => p.PostId == postId);
            if (post == null)
                return Result.NotFound("Post not found");
            var reaction = await _context.Reactions
                .FirstOrDefaultAsync(r => r.PostId == postId && r.UserId == userId);
            if (reaction != null)
            {
                _context.Reactions.Remove(reaction);
                post.ReactionCount--;
                await _context.SaveChangesAsync();
                return Result.Ok("unLiked");
            }
            else
            {
                var newReaction = new Reaction
                {
                    PostId = postId,
                    UserId = userId,
                    CreatedDate = DateTimeOffset.Now
                };
                _context.Reactions.Add(newReaction);
                post.ReactionCount++; //Tăng số lượng lượt thích trong Reaction
                await _context.SaveChangesAsync();
                return Result.Ok("liked");
            }
        }
    }
}
