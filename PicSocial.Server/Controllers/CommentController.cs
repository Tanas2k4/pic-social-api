using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using PicSocial.Server.DTOs.CommentsDto;
using PicSocial.Server.Models;
using PicSocial.Server.Services.Interfaces;

namespace PicSocial.Server.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class CommentController : ControllerBase
    {
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly ApplicationDbContext _context;
        private readonly ICommentService _commentService;
        public CommentController(UserManager<ApplicationUser> userManager, ApplicationDbContext context, ICommentService commentService)
        {
            _userManager = userManager;
            _context = context;
            _commentService = commentService;
        }

        [HttpPost("{postId}")]
        public async Task<IActionResult> CommentPost(Guid postId, [FromBody] CommentDto commentDto)
        {
            var currentUser = await _userManager.GetUserAsync(User);
            if (currentUser == null)
                return Unauthorized();

            var result = await _commentService.CommentPostAsync(postId, currentUser.Id, commentDto.Content, commentDto.ParentCommentId);

            return StatusCode(result.StatusCode, result);
        }

        //DELETE api/comment/{CommentId}?postId={postId}
        [HttpDelete("{commentId}")]
        public async Task<IActionResult> DeleteComment(Guid commentId, Guid postId)
        {
            var currentUser = await _userManager.GetUserAsync(User);
            if (currentUser == null)
                return Unauthorized();

            var result = await _commentService.DeleteCommentAsync(commentId, currentUser.Id);

            return StatusCode(result.StatusCode, new { message = result.Message });
        }
        
        //PUT api/comment/{commentId}?postId={postId}
        [HttpPut("{commentId}")]
        public async Task<IActionResult> UpdateComment(Guid commentId, Guid postId, [FromBody] CommentDto commentDto)
        {
            var currentUser = await _userManager.GetUserAsync(User);
            if (currentUser == null)
                return Unauthorized();

            var result = await _commentService.UpdateCommentAsync(commentId, currentUser.Id,commentDto.Content);
            return StatusCode(result.StatusCode, result);
        }

        //GET api/comment/{postId}
        [HttpGet("{postId}")]
        public async Task<IActionResult> GetCommentPost(Guid postId)
        {
            var result = await _commentService.GetCommentsByPostIdAsync(postId);
            return StatusCode(result.StatusCode, result.Data);
        }
    }
}