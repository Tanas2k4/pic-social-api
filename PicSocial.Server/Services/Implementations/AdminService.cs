using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PicSocial.Server.Models;
using PicSocial.Server.Services.Interfaces;

namespace PicSocial.Server.Services.Implementations
{
    public class AdminService : IAdminService
    {
        private readonly ApplicationDbContext _context;
        public AdminService(ApplicationDbContext context)
        {
            _context = context;
        }

        //get all users
        public async Task<IActionResult> GetAllUserAsync()
        {
            var users = await _context.Users
                .Select(u => new { u.AvatarUrl, u.FirstName, u.UserName, u.Email })
                .ToListAsync();
            return new OkObjectResult(users);
        }

        //delete user
        public async Task<IActionResult> DeleteUserAsync(string targetUserId) 
        {
            var targetUser = await _context.Users
                .FirstOrDefaultAsync(u => u.Id == targetUserId);
            if (targetUser == null)
                return new NotFoundObjectResult("User not found");

            _context.Users.Remove(targetUser);
            await _context.SaveChangesAsync();
            
            return new OkObjectResult("User deleted successfully");
        }

        //xem tất cả report
        public async Task<IActionResult> GetAllReportsAsync()
        {
            var reports = await _context.Reports
                .ToListAsync();
            return new OkObjectResult(reports);
        }

        //Xem tất cả report của 1 bài viết
        public async Task<IActionResult> GetReportByIdAsync(Guid postId)
        {
            var reports = await _context.Reports
                .Where(p => p.PostId == postId)
                .ToListAsync();
            return new OkObjectResult(reports);
        }
    
        //tổng số bài viết
        public async Task<IActionResult> TotalPostAsync()
        {
            var totalPosts = await _context.Posts.CountAsync();
            return new OkObjectResult(totalPosts);
        }
    }
}
