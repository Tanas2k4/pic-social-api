using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.VisualBasic;
using PicSocial.Server.DTOs;
using PicSocial.Server.Models;
using PicSocial.Server.Models.Entities;

namespace PicSocial.Server.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class ReportController : ControllerBase
    {
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly ApplicationDbContext _context;

        public ReportController(UserManager<ApplicationUser> userManager, ApplicationDbContext context)
        {
            _userManager = userManager;
            _context = context;
        }

        //POST api/report/{postId} // 
        [HttpPost("{postId}")]
        public async Task<IActionResult> ReportPost(Guid postId, [FromForm] ReportDto reportDto)
        {
            var user = await _userManager.GetUserAsync(User);
            if (user == null)
                return Unauthorized();

            var post = await _context.Posts
                .FirstOrDefaultAsync(p => p.PostId == postId);
            if (post == null)
                return NotFound();

            var report = new Report
            {
                PostId = post.PostId,
                UserId = user.Id,
                Reason = reportDto.Reason,
                CreatedDate = DateTimeOffset.Now,
                Status = "Pending"
            };

            _context.Reports.Add(report);
            await _context.SaveChangesAsync();
            return Ok(new
            {
                message = "report sent!",
                report = new
                {
                    postId = report.PostId,
                    userId = report.UserId,
                    reason = report.Reason,
                    createdDate = report.CreatedDate,
                    status = report.Status
                }
            });
        }
    }
}

