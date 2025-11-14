using System.Formats.Tar;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PicSocial.Server.Models;

namespace PicSocial.Server.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize(Roles = "Admin")]
    public class AdminController : ControllerBase
    {
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly ApplicationDbContext _context;
        public AdminController(UserManager<ApplicationUser> userManager, ApplicationDbContext context)
        {
            _userManager = userManager;
            _context = context;
        }

        //GET api/admin/users
        [HttpGet("users")]
        public async Task<IActionResult> GetAllUser()
        {
            var users = await _context.Users
                .Select(u => new { u.AvatarUrl, u.FirstName, u.UserName, u.Email })
                .ToListAsync();

            return Ok(users);
        }

        //DELETE api/admin/users/delete/{userId}
        [HttpDelete("users/{userId}")]
        public async Task<IActionResult> DeleteUser(string userId)
        {
            //gọi một user khác
            var targetUser = await _userManager.FindByIdAsync(userId);
            if (targetUser == null)
                return NotFound(new { error = "User not found"});
                
            var result = await _userManager.DeleteAsync(targetUser);
            if (!result.Succeeded)
                return BadRequest(new { error = result.Errors });
            return Ok(new { message = "delete completed!" });
        }

        //GET api/admin/reports //xem tất cả report
        [HttpGet("reports")]
        public async Task<IActionResult> GetAllReports()
        {
            var reports = await _context.Reports
                .ToListAsync();
            return Ok(reports);
        }

        //GET api/admin/reports/{postId} //xem tất cả report của 1 bài viết 
        [HttpGet("reports/{postId}")]
        public async Task<IActionResult> GetReportById (Guid postId)
        {
            var reports = await _context.Reports
                .Where(p => p.PostId == postId)
                .ToListAsync();

            return Ok(reports);
        }


        //GET api/admin/totalPost - tổng số bài viết
        [HttpGet("posts")]
        public async Task<IActionResult> TotalPost()
        {
            var allPost = await _context.Posts.ToListAsync();
            return Ok(allPost);
        }

    } 
}