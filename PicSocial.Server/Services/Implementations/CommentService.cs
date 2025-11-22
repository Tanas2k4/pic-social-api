using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.ActionConstraints;
using Microsoft.EntityFrameworkCore;
using PicSocial.Server.DTOs;
using PicSocial.Server.Models;
using PicSocial.Server.Models.Entities;
using PicSocial.Server.Services.Interfaces;
using PicSocial.Server.Shared;
namespace PicSocial.Server.Services.Implementations
{
    public class CommentService : ICommentService
    {
        private readonly ApplicationDbContext _context;
        private readonly UserManager<ApplicationUser> _userManager;
        public CommentService(ApplicationDbContext context, UserManager<ApplicationUser> userManager)
        {
            _context = context;
            _userManager = userManager;
        }

        //post comment
        public async Task<Result<CommentCreateDto>> CommentPostAsync(Guid postId, string userId, string content, Guid? parentCommentId = null)
        {
            var currentUser = await _userManager.FindByIdAsync(userId);
            if (currentUser == null)
                return Result<CommentCreateDto>.Unauthorized("user not found");

            var post = await _context.Posts
                .FirstOrDefaultAsync(p => p.PostId == postId);
            if (post == null)
                return Result<CommentCreateDto>.NotFound("post not found");

            var comment = new Comment
            {
                PostId = postId,
                UserId = userId,
                Content = content,
                ParentCommentId = parentCommentId,
                CreatedDate = DateTimeOffset.Now
            };

            _context.Comments.Add(comment);

            post.CommentCount++;
            await _context.SaveChangesAsync();

            return Result<CommentCreateDto>.Ok(new CommentCreateDto
            {
                CommentId = comment.CommentId,
                Content = comment.Content,
                CreateDate = comment.CreatedDate,
                UserName = currentUser.UserName,
                Avatar = currentUser.AvatarUrl
            });
        }

        //delete comment
        public async Task<Result> DeleteCommentAsync(Guid commentId, string currentUserId)
        {
            var currentUser = await _userManager.FindByIdAsync(currentUserId);
            if (currentUser == null)
                return Result.Unauthorized("User not found");

            var post = await _context.Posts
                .FirstOrDefaultAsync(p => p.Comments.Any(c => c.CommentId == commentId));
            if (post == null)
                return Result.NotFound("Post not found for this comment");

            var comment = await _context.Comments
                .Include(c => c.ChildComments)
                .FirstOrDefaultAsync(c => c.CommentId == commentId);
            if (comment == null)
                return Result.NotFound("Comment not found");

            if (comment.UserId != currentUserId && post.UserId != currentUserId)
                return Result.Forbidden("You cannot delete this comment");

            int removedCount = 1;

            if (comment.ChildComments.Any())
            {
                removedCount += comment.ChildComments.Count();
                _context.Comments.RemoveRange(comment.ChildComments);
            }

            _context.Comments.Remove(comment);

            post.CommentCount -= removedCount;
            if (post.CommentCount < 0) post.CommentCount = 0;

            await _context.SaveChangesAsync();

            return Result.Ok("Comment deleted");
        }


        //update comment
        public async Task<Result<CommentUpdateDto>> UpdateCommentAsync(Guid commentId, string currentUserId, string newContent)
        {
            var currentUser = await _userManager.FindByIdAsync(currentUserId);
            if (currentUser == null)
                return Result<CommentUpdateDto>.Unauthorized("User not found");
            var comment = await _context.Comments
                .Include(c => c.ChildComments)
                .FirstOrDefaultAsync(c => c.CommentId == commentId && c.UserId == currentUserId);
            if (comment == null || comment.ParentCommentId != null)
                return Result<CommentUpdateDto>.NotFound("Comment not found or you do't have permission");

            comment.Content = newContent;
            comment.UpdatedDate = DateTimeOffset.Now;

            await _context.SaveChangesAsync();
            return Result<CommentUpdateDto>.Ok(new CommentUpdateDto
            {
                CommentId = comment.CommentId,
                Content = comment.Content,
                UpdateDate = comment.UpdatedDate,
                UserName = currentUser.UserName,
                Avatar = currentUser.AvatarUrl
            });
        }

        //Get comment by postId
        public async Task<Result<List<CommentPostDto>>> GetCommentsByPostIdAsync(Guid postId)
        {
            var comments = await _context.Comments
                .Where(c => c.PostId == postId && c.ParentCommentId == null)
                .Include(c => c.ChildComments)
                .ThenInclude(cc => cc.User)
                .Include(c => c.User)
                .ToListAsync();
            var dto = comments.Select(c => new CommentPostDto
            {
                CommentId = c.CommentId,
                Content = c.Content,
                CreateDate = c.CreatedDate,
                UpdateDate = c.UpdatedDate,
                UserName = c.User.UserName,
                Avatar = c.User.AvatarUrl,
                Replies = c.ChildComments.Select(cc => new CommentPostDto
                {
                    CommentId = cc.CommentId,
                    Content = cc.Content,
                    CreateDate = cc.CreatedDate,
                    UpdateDate = cc.UpdatedDate,
                    UserName = cc.User.UserName,
                    Avatar = cc.User.AvatarUrl
                }).ToList()
            }).ToList();
            return Result<List<CommentPostDto>>.Ok(dto);
        }
    }
}
