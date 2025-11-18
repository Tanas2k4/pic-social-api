using System.Formats.Tar;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
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
        private readonly ApplicationDbContext _context;
        private readonly IAdminService _adminService;
        public AdminController(UserManager<ApplicationUser> userManager, ApplicationDbContext context, IAdminService adminService)
        {
            _userManager = userManager;
            _context = context;
            _adminService = adminService;
        }

        //GET api/admin/users
        [HttpGet("users")]
        public async Task<IActionResult> GetAllUser()
        {
            var users = await _adminService.GetAllUserAsync();
            return Ok(users);
        }

        //DELETE api/admin/user/{userId}
        [HttpDelete("user/{userId}")]
        public async Task<IActionResult> DeleteUser(string userId)
        {
           var result = await _adminService.DeleteUserAsync(userId);
            return Ok(result);
        }

        //GET api/admin/reports //xem tất cả report
        [HttpGet("reports")]
        public async Task<IActionResult> GetAllReports()
        {
            var reports = await _adminService.GetAllReportsAsync();
            return Ok(reports);
        }

        //GET api/admin/reports/{postId} //xem tất cả report của 1 bài viết 
        [HttpGet("reports/{postId}")]
        public async Task<IActionResult> GetReportById (Guid postId)
        {
            var reports = await _adminService.GetReportByIdAsync(postId);
            return Ok(reports);
        }

        //GET api/admin/totalPost - tổng số bài viết
        [HttpGet("posts")]
        public async Task<IActionResult> TotalPost()
        {
            var allPost = await _adminService.TotalPostAsync();
            return Ok(allPost);
        }
    } 
}