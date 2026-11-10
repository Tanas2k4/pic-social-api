using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using PicSocial.Server.DTOs.CommentsDto;
using PicSocial.Server.Models;
using PicSocial.Server.Services.Interfaces;
using PicSocial.Server.Shared;

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

        /// <summary>
        /// Creates a new comment or reply on a post.
        /// </summary>
        /// <param name="postId">The ID of the post to comment on.</param>
        /// <param name="commentDto">Comment content and optional ParentCommentId for replies.</param>
        /// <returns>
        /// 201 Created: Full result object containing the created comment details.<br/>
        /// 401 Unauthorized or 404 Not Found: Full result object with error message.
        /// </returns>
        /// <response code="401">You don't have permission</response>
        /// <response code="404">User not found </response>
        [ProducesResponseType(typeof(Results<CommentCreateDto>), 200)]
        [HttpPost("{postId}")]
        public async Task<IActionResult> CommentPost(Guid postId, [FromBody] CommentDto commentDto)
        {
            var currentUser = await _userManager.GetUserAsync(User);
            if (currentUser == null)
                return Unauthorized();

            var result = await _commentService.CommentPostAsync(postId, currentUser.Id, commentDto.Content, commentDto.ParentCommentId);
            return StatusCode(result.StatusCode, result);
        }

        /// <summary>
        /// Deletes a comment and its replies. Only the comment owner or post owner can delete.
        /// </summary>
        /// <param name="commentId">The ID of the comment to delete.</param>
        /// <returns>
        /// 200 OK: Simple object with success message.<br/>
        /// 401, 403, 404: Simple object with error message.
        /// </returns>
        /// <response code="200">Comment deleted </response>
        /// <response code="401">User not found</response>
        /// <response code="403">You cannot delete this comment</response>
        /// <response code="404">Comment not found</response>
        [HttpDelete("{commentId}")]
        public async Task<IActionResult> DeleteComment(Guid commentId)
        {
            var currentUser = await _userManager.GetUserAsync(User);
            if (currentUser == null)
                return Unauthorized();

            var result = await _commentService.DeleteCommentAsync(commentId, currentUser.Id);
            return StatusCode(result.StatusCode, new { message = result.Message });
        }

        /// <summary>
        /// Updates the content of a root comment (replies cannot be edited).
        /// Only the comment owner can update it.
        /// </summary>
        /// <param name="commentId">The ID of the comment to update.</param>
        /// <param name="commentDto">New comment content.</param>
        /// <returns>
        /// 200 OK: Full result object containing updated comment details.<br/>
        /// 401 or 404: Full result object with error message.
        /// </returns>
        /// <response code="401">User not found</response>
        /// <response code="404">Comment not found or you don't have permission</response>
        [ProducesResponseType(typeof(Results<CommentUpdateDto>), 200)]
        [HttpPut("{commentId}")]
        public async Task<IActionResult> UpdateComment(Guid commentId, [FromBody] CommentDto commentDto)
        {
            var currentUser = await _userManager.GetUserAsync(User);
            if (currentUser == null)
                return Unauthorized();

            var result = await _commentService.UpdateCommentAsync(commentId, currentUser.Id, commentDto.Content);
            return StatusCode(result.StatusCode, result);
        }

        /// <summary>
        /// Retrieves all root comments and their replies for a post.
        /// </summary>
        /// <param name="postId">The ID of the post.</param>
        /// <returns>
        /// 200 OK: Direct list of CommentPostDto (with nested replies).<br/>
        /// If no comments, returns empty array [].<br/>
        /// Note: Errors (e.g., post not found) are not currently handled — consider adding check.
        /// </returns>
        /// <response code="200">Returns array of CommentPostDto</response>
        [HttpGet("{postId}")]
        [ProducesResponseType(typeof(List<CommentPostDto>), 200)]
        public async Task<IActionResult> GetCommentPost(Guid postId)
        {
            var result = await _commentService.GetCommentsByPostIdAsync(postId);
            return StatusCode(result.StatusCode, result.Data);
        }
    }
}