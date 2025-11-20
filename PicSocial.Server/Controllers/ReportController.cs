using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.VisualBasic;
using PicSocial.Server.DTOs;
using PicSocial.Server.Models;
using PicSocial.Server.Models.Entities;
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
        public ReportController(UserManager<ApplicationUser> userManager, IReportService _service)
        {
            _userManager = userManager;
            this._service = _service;
        }

        //POST api/report/{postId} //send report to admin 
        [HttpPost("{postId}")]
        public async Task<IActionResult> ReportPost(Guid postId, [FromForm] ReportDto reportDto)
        {
            var currentUser = await _userManager.GetUserAsync(User);
            if (currentUser == null)
                return Unauthorized();

            var result = await _service.ReportPostAsync(postId, currentUser.Id,  reportDto.Reason);
            if(!result)
            {
                return BadRequest(new { message = "Unable to report the post." });
            }
            return Ok(new { message = "Post reported successfully." });
        }
    }
}

