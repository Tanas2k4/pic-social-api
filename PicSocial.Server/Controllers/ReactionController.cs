using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using PicSocial.Server.Models;
using PicSocial.Server.Services.Interfaces;

namespace PicSocial.Server.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class ReactionController : ControllerBase
    {
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly IReactionService _reactionService;

        public ReactionController(UserManager<ApplicationUser> userManager, IReactionService reactionService)
        {
            _userManager = userManager;
            _reactionService = reactionService;
        }

        /// <summary>
        /// Toggles a like/reaction on a post.
        /// If the authenticated user has already liked the post, this will unlike it.<br/>
        /// If not, it will add a like.
        /// </summary>
        /// <param name="postId">The ID of the post to react to.</param>
        /// <returns>
        /// 200 OK: Simple object with success message ("liked" or "unLiked").<br/>
        /// 401 Unauthorized: If user is not authenticated or not found.<br/>
        /// 404 Not Found: If the post does not exist.
        /// </returns>
        /// <response code="200">{ "message": "liked" } or { "message": "unLiked" }</response>
        /// <response code="401">Unauthorized</response>
        /// <response code="404">Post not found</response>
        [HttpPost("{postId}")]
        public async Task<IActionResult> ReactionPost(Guid postId)
        {
            var currentUser = await _userManager.GetUserAsync(User);
            if (currentUser == null)
                return Unauthorized();

            var result = await _reactionService.ReactionPostAsync(currentUser.Id, postId);
            return StatusCode(result.StatusCode, new { message = result.Message });
        }
    }
}