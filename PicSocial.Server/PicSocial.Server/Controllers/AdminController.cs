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

        //GET api/admin/user
        [HttpGet("user")]
        public async Task<IActionResult> GetAllUser()
        {
            var users = await _context.Users
                .Select(u => new { u.AvatarUrl, u.FirstName, u.UserName, u.Email })
                .ToListAsync();

            return Ok(users);
        }
        
        //GET api/admin/report/{postId} //xem report được gửi về 
        public async Task<IActionResult> GetAll(Guid postId, Guid roleId)
        {

            var reports = await _context.Reports
                .Where(p => p.PostId == postId)
                .ToListAsync();

            return Ok(reports);          
        }
    }

    
    
}