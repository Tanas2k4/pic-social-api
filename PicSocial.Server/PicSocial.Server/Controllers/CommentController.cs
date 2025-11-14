using System.Net.WebSockets;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PicSocial.Server.DTOs;
using PicSocial.Server.Models;
using PicSocial.Server.Models.Entities;

namespace PicSocial.Server.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class CommentController : ControllerBase
    {
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly ApplicationDbContext _context;
        public CommentController(UserManager<ApplicationUser> userManager, ApplicationDbContext context)
        {
            _userManager = userManager;
            _context = context;
        }

        //POST api/comment/{postId}
        [HttpPost("{postId}")]
        public async Task<IActionResult> CommentPost(Guid postId, [FromBody] CommentDto commentDto)
        {
            var currentUser = await _userManager.GetUserAsync(User);
            if (currentUser == null)
                return Unauthorized();

            var post = _context.Posts.FirstOrDefault(p => p.PostId == postId);
            if (post == null)
                return BadRequest();

            var comment = new Comment
            {
                PostId = postId,
                UserId = currentUser.Id,
                Content = commentDto.Content,
                ParentCommentId = commentDto.ParentCommentId,
                CreatedDate = DateTimeOffset.Now
            };

            _context.Comments.Add(comment);
            post.CommentCount++;
            await _context.SaveChangesAsync();

            return Ok(new
            {
                message = "commented",
                comment = new
                {
                    comment.CommentId,
                    comment.Content,
                    comment.CreatedDate,
                    userName = currentUser.UserName,
                    avatar = currentUser.AvatarUrl
                }
            });
        }

        //DELETE api/comment/{CommentId}?postId={postId}
        [HttpDelete("{commentId}")]
        public async Task<IActionResult> DeleteComment(Guid commentId, Guid postId)
        {
            var currentUser = await _userManager.GetUserAsync(User);
            if (currentUser == null)
                return Unauthorized();

            var post = await _context.Posts
                .FirstOrDefaultAsync(p => p.PostId == postId);
            if (post == null)
                return NotFound();

            //nếu xóa comment thì reply comment cũng bị mất theo 
            var comment = await _context.Comments
            .Include(c => c.ChildComments)
            .FirstOrDefaultAsync(c => c.CommentId == commentId);
            if (comment == null)
                    return NotFound();

            //check quyền được xóa comment (chủ tus và user cmt)
            if (comment.UserId != currentUser.Id && post.UserId != currentUser.Id )
                return Forbid();

            int removedCount = 1; //xóa ít nhất 1 vì xóa chính nó

            //Nếu comment gốc có reply => xóa reply
            if (comment.ChildComments.Any())
            {
                removedCount += comment.ChildComments.Count();
                _context.Comments.RemoveRange(comment.ChildComments);
            }

            _context.Comments.Remove(comment);
            
            //tính lại số lượng comment
            post.CommentCount -= removedCount; 
            if (comment.Post.CommentCount < 0) comment.Post.CommentCount = 0;

            await _context.SaveChangesAsync();
            return Ok(new { message = "deleted comment" });
        }

        //PUT api/comment/{commentId}?postId={postId}
        [HttpPut("{commentId}")]
        public async Task<IActionResult> UpdateComment(Guid commentId, Guid postId, [FromForm] CommentDto commentDto)
        {
            var currentUser = await _userManager.GetUserAsync(User);
            if (currentUser == null)
                return Unauthorized();

            var comment = await _context.Comments
                .Include(c => c.ChildComments)
                .FirstOrDefaultAsync(c => c.CommentId == commentId && c.UserId == currentUser.Id); //Chính chủ mới được sửa comment
            if (comment == null || comment.ParentCommentId != null)
                return NotFound("comment not found or you don't have permission");

            var post = await _context.Posts
                .FirstOrDefaultAsync(p => p.PostId == postId);
            if (post == null)
                return NotFound("Post not found");

            //cập nhật 
            comment.Content = commentDto.Content;
            comment.UpdatedDate = DateTimeOffset.Now;

            await _context.SaveChangesAsync();

            return Ok(new
            {
                massage = "comment updated",
                newComment = new
                {
                    comment.CommentId,
                    comment.Content,
                    comment.UpdatedDate,
                    userName = currentUser.UserName,
                    avatar = currentUser.AvatarUrl
                }
            });
        }

        //GET api/comment/{postId}
        [HttpGet("{postId}")]
        public async Task<IActionResult> GetCommentPost(Guid postId)
        {
            var comments = await _context.Comments
                .Where(c => c.PostId == postId && c.ParentCommentId == null)
                .Include(c => c.ChildComments)
                .ToListAsync();
                
            return Ok(comments);
        }
    }
}