using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using PicSocial.Server.Models;
using PicSocial.Server.Services.Interfaces;

namespace PicSocial.Server.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize(Roles = "Admin")]
    public class AdminController : ControllerBase
    {
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly IAdminService _adminService;

        public AdminController(UserManager<ApplicationUser> userManager, IAdminService adminService)
        {
            _userManager = userManager;
            _adminService = adminService;
        }

        /// <summary>
        /// Retrieves a list of all users in the system (Admin only).
        /// </summary>
        /// <returns>
        /// 200 OK: Array of objects containing AvatarUrl, FullName, UserName, and Email for each user.
        /// </returns>
        /// <response code="200">Returns list of user summaries</response>
        /// <response code="401">Unauthorized (not authenticated)</response>
        /// <response code="403">Forbidden (authenticated but not Admin)</response>
        [HttpGet("users")]
        public async Task<IActionResult> GetAllUser()
        {
            var result = await _adminService.GetAllUserAsync();
            return Ok(result);
        }

        /// <summary>
        /// Deletes a user account and all associated data (posts, photos, reactions, comments, shares, follows, etc.).
        /// Only Admins can delete other users. Regular users can only delete their own account if somehow accessing this endpoint.
        /// </summary>
        /// <param name="userId">The ID of the user to delete.</param>
        /// <returns>
        /// 200 OK: true (deletion successful).<br/>
        /// 400 Bad Request: Deletion failed (with error message).<br/>
        /// 401 Unauthorized: If current user not authenticated.<br/>
        /// 403 Forbidden: If not Admin and trying to delete another user.
        /// </returns>
        /// <response code="200">true</response>
        /// <response code="400">delete user failed</response>
        /// <response code="401">Unauthorized</response>
        /// <response code="403">Forbidden (not authorized to delete this user)</response>
        [HttpDelete("user/{userId}")]
        public async Task<IActionResult> DeleteUser(string userId)
        {
            var currentUser = await _userManager.GetUserAsync(User);
            if (currentUser == null)
                return Unauthorized();

            var result = await _adminService.DeleteUserAsync(userId, currentUser.Id);
            if (!result)
            {
                return BadRequest(new { message = "Xóa người dùng thất bại" });
            }
            return Ok(result);
        }

        /// <summary>
        /// Retrieves all reports submitted in the system (Admin only).
        /// </summary>
        /// <returns>
        /// 200 OK: Array of all Report entities.
        /// </returns>
        /// <response code="200">Returns list of all reports</response>
        /// <response code="401">Unauthorized</response>
        /// <response code="403">Forbidden (not Admin)</response>
        [HttpGet("reports")]
        public async Task<IActionResult> GetAllReports()
        {
            var result = await _adminService.GetAllReportsAsync();
            return Ok(result);
        }

        /// <summary>
        /// Retrieves all reports submitted for a specific post (Admin only).
        /// </summary>
        /// <param name="postId">The ID of the post.</param>
        /// <returns>
        /// 200 OK: Array of Report entities for the specified post (empty array if none).
        /// </returns>
        /// <response code="200">Returns list of reports for the post</response>
        /// <response code="401">Unauthorized</response>
        /// <response code="403">Forbidden (not Admin)</response>
        [HttpGet("reports/{postId}")]
        public async Task<IActionResult> GetReportById(Guid postId)
        {
            var result = await _adminService.GetReportByIdAsync(postId);
            return Ok(result);
        }

        /// <summary>
        /// Returns the total number of posts in the system (Admin only).
        /// </summary>
        /// <returns>
        /// 200 OK: Integer representing the total post count.
        /// </returns>
        /// <response code="200">Returns total post count</response>
        /// <response code="401">Unauthorized</response>
        /// <response code="403">Forbidden (not Admin)</response>
        [HttpGet("posts")]
        public async Task<IActionResult> TotalPost()
        {
            var result = await _adminService.TotalPostAsync();
            return Ok(result);
        }
    }
}