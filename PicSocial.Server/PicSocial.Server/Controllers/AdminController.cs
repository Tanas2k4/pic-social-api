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
        [HttpDelete("users/delete/{userId}")]
        public async Task<IActionResult> DeleteUser(string userId)
        {
            var user = await _userManager.GetUserAsync(User);
            if (user == null)
                return Unauthorized();

            //gọi một user khác
            var targetUser = await _userManager.FindByIdAsync(userId);
            if (targetUser == null)
                return NotFound(new { error = "User not found"});
                
            var result = await _userManager.DeleteAsync(targetUser);
            if (!result.Succeeded)
                return BadRequest(new { error = result.Errors });
            return Ok(new { message = "delete completed!" });
        }


        //GET api/admin/reports/{postId} //xem report được gửi về 
        [HttpGet("reports/{postId}")]
        public async Task<IActionResult> GetAll(Guid postId)
        {

            var reports = await _context.Reports
                .Where(p => p.PostId == postId)
                .ToListAsync();

            return Ok(reports);
        }

        //PATCH 
    } 
}