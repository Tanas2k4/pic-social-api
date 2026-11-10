using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using PicSocial.Server.DTOs.SharesDto;
using PicSocial.Server.Extensions;
using PicSocial.Server.Services.Interfaces;

namespace PicSocial.Server.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class ShareController : ControllerBase
    {
        private readonly IShareService _service;

        public ShareController(IShareService service)
        {
            _service = service;
        }

        /// <summary>
        /// Shares a post internally or to an external platform.
        /// Creates a new share record and increments the post's share count.
        /// </summary>
        /// <param name="postId">The ID of the post to share.</param>
        /// <param name="shareDto">Contains optional Caption and SharePlatform (defaults to "Internal" if not provided).</param>
        /// <returns>
        /// 200 OK: Full ShareCreateDto containing success message and detailed share information (including post owner and photo URLs).<br/>
        /// 401 Unauthorized: If user is not authenticated.<br/>
        /// 404 Not Found: If the current user or the post does not exist.
        /// </returns>
        /// <response code="200">Returns ShareCreateDto with Message and Share details</response>
        /// <response code="401">You don't have permission</response>
        /// <response code="404">user not found / Post not found</response>
        [HttpPost("{postId}")]
        [Consumes("multipart/form-data")]
        [ProducesResponseType(typeof(ShareCreateDto), 200)]
        public async Task<IActionResult> SharePost(Guid postId, [FromForm] ShareDto shareDto)
        {
            var currentUserId = User.GetUserId();
            if (string.IsNullOrEmpty(currentUserId))
                return Unauthorized(new { message = "You don't have permission" });

            var result = await _service.SharePostAsync(postId, currentUserId, shareDto);
            return StatusCode(result.StatusCode, result.Success ? result.Data : new { message = result.Message });
        }

        /// <summary>
        /// Deletes a previously created share.
        /// Only the user who created the share or an Admin can delete it.
        /// Decrements the post's share count upon successful deletion.
        /// </summary>
        /// <param name="shareId">The ID of the share record to delete.</param>
        /// <param name="postId">The ID of the original post (required query parameter for validation).</param>
        /// <returns>
        /// 200 OK: Simple object with success message.<br/>
        /// 401 Unauthorized: If user is not authenticated or lacks permission.<br/>
        /// 404 Not Found: If current user, share, or post does not exist.
        /// </returns>
        /// <response code="200">Share deleted successfully</response>
        /// <response code="401">Unauthorized to delete this share</response>
        /// <response code="404">Current user not found / Share not found / Post not found</response>
        [HttpDelete("{shareId}")]
        public async Task<IActionResult> DeleteSharePost([FromQuery] Guid postId, Guid shareId)
        {
            var currentUserId = User.GetUserId();
            if (string.IsNullOrEmpty(currentUserId))
                return Unauthorized();

            var result = await _service.DeleteSharePostAsync(postId, shareId, currentUserId);

            return StatusCode(result.StatusCode, new { message = result.Message });
        }
    }
}