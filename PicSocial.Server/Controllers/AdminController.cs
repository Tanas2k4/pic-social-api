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
            var result = await _adminService.GetAllUserAsync();
            return Ok(result);
        }

        //DELETE api/admin/user/{userId}
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

        //GET api/admin/reports //xem tất cả report
        [HttpGet("reports")]
        public async Task<IActionResult> GetAllReports()
        {
            var result = await _adminService.GetAllReportsAsync();
            return Ok(result);
        }

        //GET api/admin/reports/{postId} //xem tất cả report của 1 bài viết 
        [HttpGet("reports/{postId}")]
        public async Task<IActionResult> GetReportById (Guid postId)
        {
            var result = await _adminService.GetReportByIdAsync(postId);
            return Ok(result);
        }

        //GET api/admin/totalPost - tổng số bài viết
        [HttpGet("posts")]
        public async Task<IActionResult> TotalPost()
        {
            var result = await _adminService.TotalPostAsync();
            return Ok(result);
        }
    } 
}