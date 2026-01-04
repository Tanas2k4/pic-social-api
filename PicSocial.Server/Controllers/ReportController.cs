using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using PicSocial.Server.DTOs.ReportsDto;
using PicSocial.Server.Models;
using PicSocial.Server.Services.Interfaces;

namespace PicSocial.Server.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class ReportController : ControllerBase
    {
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly IReportService _service;

        public ReportController(UserManager<ApplicationUser> userManager, IReportService service)
        {
            _userManager = userManager;
            _service = service;
        }

        /// <summary>
        /// Submits a report for a post to the administrators.
        /// The report includes a reason provided by the authenticated user.
        /// </summary>
        /// <param name="postId">The ID of the post being reported.</param>
        /// <param name="reportDto">Contains the Reason for the report.</param>
        /// <returns>
        /// 200 OK: Simple object with success message.<br/>
        /// 401 Unauthorized: If user is not authenticated or not found.<br/>
        /// 404 Not Found: If the post does not exist.
        /// </returns>
        /// <response code="200">{report sent</response>
        /// <response code="401">Unauthorized</response>
        /// <response code="404">Post not found</response>
        [HttpPost("{postId}")]
        [Consumes("multipart/form-data")]
        public async Task<IActionResult> ReportPost(Guid postId, [FromForm] ReportDto reportDto)
        {
            var currentUser = await _userManager.GetUserAsync(User);
            if (currentUser == null)
                return Unauthorized();

            var result = await _service.ReportPostAsync(postId, currentUser.Id, reportDto.Reason);

            return StatusCode(result.StatusCode, new { message = result.Message });
        }
    }
}