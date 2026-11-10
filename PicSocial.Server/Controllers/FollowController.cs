using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using PicSocial.Server.DTOs.FollowsDto;
using PicSocial.Server.Extensions;
using PicSocial.Server.Services.Interfaces;

namespace PicSocial.Server.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class FollowController : ControllerBase
    {
        private readonly IFollowService _service;

        public FollowController(IFollowService service)
        {
            _service = service;
        }

        /// <summary>
        /// Checks whether the current authenticated user is following a specific user.
        /// </summary>
        /// <param name="userId">The ID of the user to check.</param>
        /// <returns>
        /// 200 OK: Object with boolean message indicating true (following) or false (not following).<br/>
        /// 401 Unauthorized: If user is not authenticated.
        /// </returns>
        /// <response code="200">{ "message": true/false }</response>
        /// <response code="401">Unauthorized</response>
        [HttpGet("isFollowing/{userId}")]
        public async Task<IActionResult> IsFollowing(string userId)
        {
            var currentUserId = User.GetUserId();
            if (string.IsNullOrEmpty(currentUserId))
                return Unauthorized();

            var isFollowing = await _service.IsFollowingAsync(currentUserId, userId);
            return Ok(new { message = isFollowing });
        }

        /// <summary>
        /// Allows the current user to follow another user.
        /// </summary>
        /// <param name="followDto">Contains the Id of the user to follow.</param>
        /// <returns>
        /// 200 OK: Success message.<br/>
        /// 400 Bad Request: Already following or trying to follow self.<br/>
        /// 401 Unauthorized: If current user not authenticated.<br/>
        /// 404 Not Found: If target user or current user not found.
        /// </returns>
        /// <response code="200">Followed successfully</response>
        /// <response code="400">You are already following this user / You cannot follow yourself</response>
        /// <response code="401">Unauthorized</response>
        /// <response code="404">User not found</response>
        [HttpPost]
        public async Task<IActionResult> FollowUser([FromBody] FollowDto followDto)
        {
            var currentUserId = User.GetUserId();
            if (string.IsNullOrEmpty(currentUserId))
                return Unauthorized();

            var result = await _service.FollowUserAsync(currentUserId, followDto);

            return StatusCode(result.StatusCode, new { message = result.Message });
        }

        /// <summary>
        /// Allows the current user to unfollow another user.
        /// </summary>
        /// <param name="userId">The ID of the user to unfollow.</param>
        /// <returns>
        /// 200 OK: Success message.<br/>
        /// 400 Bad Request: If not currently following the user.<br/>
        /// 401 Unauthorized: If current user not authenticated.<br/>
        /// 404 Not Found: If target user not found.
        /// </returns>
        /// <response code="200">Successfully unfollowed the user.</response>
        /// <response code="400">you haven't followed this user before</response>
        /// <response code="401">Unauthorized</response>
        /// <response code="404">User not found</response>
        [HttpDelete("{userId}")]
        public async Task<IActionResult> UnfollowUser(string userId)
        {
            var currentUserId = User.GetUserId();
            if (string.IsNullOrEmpty(currentUserId))
                return Unauthorized();

            var result = await _service.UnfollowUserAsync(currentUserId, userId);

            return StatusCode(result.StatusCode, new { message = result.Message });
        }

        /// <summary>
        /// Retrieves the list of followers for a specific user.
        /// </summary>
        /// <param name="id">The ID of the user whose followers to retrieve.</param>
        /// <returns>
        /// 200 OK: Array of objects containing FollowerUserName, FollowerFirstName, and FollowerAvatar.<br/>
        /// 404 Not Found: If the specified user does not exist.
        /// </returns>
        /// <response code="200">Returns list of followers</response>
        /// <response code="404">User not found.</response>
        [ProducesResponseType(typeof(List<FollowerItemDto>), 200)]
        [HttpGet("followers/{id}")]
        public async Task<IActionResult> GetFollowers(string id)
        {
            var result = await _service.GetFollowerAsync(id);
            return StatusCode(result.StatusCode, result.Success ? result.Data : new { message = result.Message });
        }

        /// <summary>
        /// Retrieves the list of users that a specific user is following.
        /// </summary>
        /// <param name="id">The ID of the user whose following list to retrieve.</param>
        /// <returns>
        /// 200 OK: Array of objects containing FollowingUserName, FollowingFirstName, and FollowingAvatar.<br/>
        /// 404 Not Found: If the specified user does not exist.
        /// </returns>
        /// <response code="200">Returns list of followed users</response>
        /// <response code="404">User not found.</response>
        [ProducesResponseType(typeof(List<FollowingItemDto>), 200)]
        [HttpGet("following/{id}")]
        public async Task<IActionResult> GetFollowing(string id)
        {
            var result = await _service.GetFollowingAsync(id);
            return StatusCode(result.StatusCode, result.Success ? result.Data : new { message = result.Message });
        }
    }
}