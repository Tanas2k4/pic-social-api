using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using PicSocial.Server.Models;
using PicSocial.Server.DTOs.PostsDto;
using PicSocial.Server.Services.Interfaces;

namespace PicSocial.Server.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class PostController : ControllerBase
    {
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly IPostService _postService;

        public PostController(UserManager<ApplicationUser> userManager, IPostService postService)
        {
            _userManager = userManager;
            _postService = postService;
        }

        /// <summary>
        /// Creates a new post with one or more photos.
        /// </summary>
        /// <param name="title">Optional title/caption for the post.</param>
        /// <param name="files">One or more image files to upload.</param>
        /// <param name="licenseId">Optional license ID. If not provided, defaults to "Royalty-Free".</param>
        /// <returns>
        /// 200 OK: Full PostResponseDto containing the created post and its photos.<br/>
        /// 400 Bad Request: No files uploaded, invalid license, or default license missing.<br/>
        /// 401 Unauthorized: If user is not authenticated or not found.
        /// </returns>
        /// <response code="200">Returns PostResponseDto</response>
        /// <response code="400">No files uploaded. / Licences not found / Default license 'Royalty-Free' not found in database.</response>
        /// <response code="401">User not found</response>
        [HttpPost]
        [Consumes("multipart/form-data")]
        [ProducesResponseType(typeof(PostResponseDto), 200)]
        public async Task<IActionResult> UploadPhoto([FromForm] string? title, [FromForm] List<IFormFile> files, [FromForm] Guid? licenseId)
        {
            var currentUser = await _userManager.GetUserAsync(User);
            if (currentUser == null)
                return Unauthorized();

            var result = await _postService.UploadPhotoAsync(currentUser.Id, title, files, licenseId);
            return StatusCode(result.StatusCode, result.Success ? result.Data : new { message = result.Message });
        }

        /// <summary>
        /// Deletes a post and all its associated photos (from database and Google Cloud Storage).
        /// Only the post owner or an Admin can delete.
        /// </summary>
        /// <param name="postId">The ID of the post to delete.</param>
        /// <returns>
        /// 200 OK: Simple object with success message.<br/>
        /// 401 Unauthorized: If user is not authenticated or not found.<br/>
        /// 403 Forbidden: If user is not the owner and not an Admin.<br/>
        /// 404 Not Found: If the post does not exist.
        /// </returns>
        /// <response code="200">Post and associated photos deleted successfully.</response>
        /// <response code="401">User not found</response>
        /// <response code="403">you don't have permission</response>
        /// <response code="404">Post not found</response>
        [HttpDelete("{postId}")]
        public async Task<IActionResult> DeletePost(Guid postId)
        {
            var currentUser = await _userManager.GetUserAsync(User);
            if (currentUser == null)
                return Unauthorized();

            var result = await _postService.DeletePostAsync(postId, currentUser.Id);
            return StatusCode(result.StatusCode, new { message = result.Message });
        }

        /// <summary>
        /// Updates the title and/or license of an existing post.
        /// Only the post owner can update.
        /// </summary>
        /// <param name="postId">The ID of the post to update.</param>
        /// <param name="updatePostDto">Contains optional new Title and LicenseId.</param>
        /// <returns>
        /// 200 OK: Updated PostResponseDto containing the modified post details.<br/>
        /// 400 Bad Request: If specified license does not exist.<br/>
        /// 401 Unauthorized: If user is not authenticated or not found.<br/>
        /// 404 Not Found: If post not found or user does not own it.
        /// </returns>
        /// <response code="200">Returns updated PostResponseDto</response>
        /// <response code="400">License not found</response>
        /// <response code="401">User not found</response>
        /// <response code="404">Post not found or you do not have permission to update this post.</response>
        [HttpPatch("{postId}")]
        [Consumes("multipart/form-data")]
        [ProducesResponseType(typeof(PostResponseDto), 200)]
        public async Task<IActionResult> UpdatePost(Guid postId, [FromForm] PostUpdateDto updatePostDto)
        {
            var currentUser = await _userManager.GetUserAsync(User);
            if (currentUser == null)
                return Unauthorized();

            var result = await _postService.UpdatePostAsync(postId, currentUser.Id, updatePostDto.Title, updatePostDto.LicenseId);
            return StatusCode(result.StatusCode, result.Success ? result.Data : new { message = result.Message });
        }

        /// <summary>
        /// Retrieves all posts (with public photos only) for a specific user, ordered by newest first.
        /// </summary>
        /// <param name="userId">The ID of the user whose posts to retrieve.</param>
        /// <returns>
        /// 200 OK: List of PostResponseDto objects.<br/>
        /// 404 Not Found: If user has no posts or user does not exist.
        /// </returns>
        /// <response code="200">Returns List&lt;PostResponseDto&gt;</response>
        /// <response code="404">No posts found for the specified user. / User not found.</response>
        [HttpGet("{userId}")]
        [ProducesResponseType(typeof(List<PostResponseDto>), 200)]
        public async Task<IActionResult> GetPostsByUser(string userId)
        {
            var user = await _userManager.FindByIdAsync(userId);
            if (user == null)
                return NotFound("User not found.");

            var results = await _postService.GetPostsByUserAsync(userId);
            return StatusCode(results.StatusCode, results.Success ? results.Data : new { message = results.Message });
        }

        /// <summary>
        /// Retrieves a single post by ID, including only public photos.
        /// Accessible to any authenticated user.
        /// </summary>
        /// <param name="postId">The ID of the post to view.</param>
        /// <returns>
        /// 200 OK: PostResponseDto containing post details and public photos.<br/>
        /// 404 Not Found: If the post does not exist.
        /// </returns>
        /// <response code="200">Returns PostResponseDto</response>
        /// <response code="404">Post not found.</response>
        [HttpGet("view/{postId}")]
        [ProducesResponseType(typeof(PostResponseDto), 200)]
        public async Task<IActionResult> GetPost(Guid postId)
        {
            var result = await _postService.GetPostByIdAsync(postId);
            return StatusCode(result.StatusCode, result.Success ? result.Data : new { message = result.Message });
        }
    }
}