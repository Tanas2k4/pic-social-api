using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using PicSocial.Server.DTOs.AdminDto;
using PicSocial.Server.Models;
using PicSocial.Server.Models.Entities;
using PicSocial.Server.Services.Interfaces;

namespace PicSocial.Server.Services.Implementations
{
    public class AdminService : IAdminService
    {
        private readonly ApplicationDbContext _context;
        private readonly UserManager<ApplicationUser> _userManager;
        public AdminService(ApplicationDbContext context, UserManager<ApplicationUser> userManager)
        {
            _context = context;
            _userManager = userManager;
        }

        //get all users
        public async Task<List<UserSummaryDto>> GetAllUserAsync()
        {
            var users = await _context.Users
                .Select(u => new UserSummaryDto
                {
                    AvatarUrl = u.AvatarUrl,
                    FullName = u.FullName,
                    UserName = u.UserName,
                    Email = u.Email
                })
                .ToListAsync();
            return users;
        }

        //delete user
        public async Task<bool> DeleteUserAsync(string targetUserId, string currentUserId)
        {
            // Chỉ admin hoặc chính chủ mới được xóa
            var currentUser = await _userManager.FindByIdAsync(currentUserId);
            if(currentUser == null)
                throw new UnauthorizedAccessException("User not found");
                
            var isAdmin = await _userManager.IsInRoleAsync(currentUser, "Admin");

            if (targetUserId != currentUserId && !isAdmin)
                throw new UnauthorizedAccessException("Bạn chỉ được xóa tài khoản của mình");

            var user = await _context.Users
                .Include(u => u.Posts)
                .Include(u => u.FollowerFollows)   // người follow user này
                .Include(u => u.FollowedFollows)   // user này đang follow ai
                .Include(u => u.Albums)
                .FirstOrDefaultAsync(u => u.Id == targetUserId);

            if (user == null)
                throw new KeyNotFoundException("User not found");

            using var transaction = await _context.Database.BeginTransactionAsync();

            try
            {
                // 1. Cập nhật count cho những người bị ảnh hưởng
                if (user.FollowedFollows.Any())
                {
                    var followedUserIds = user.FollowedFollows.Select(f => f.FollowerId).ToList();
                    await _context.Users
                        .Where(u => followedUserIds.Contains(u.Id))
                        .ExecuteUpdateAsync(u => u
                            .SetProperty(x => x.FollowingCount, x => x.FollowingCount - 1));
                }

                if (user.FollowerFollows.Any())
                {
                    var followerUserIds = user.FollowerFollows.Select(f => f.FollowedId).ToList();
                    await _context.Users
                        .Where(u => followerUserIds.Contains(u.Id))
                        .ExecuteUpdateAsync(u => u
                            .SetProperty(x => x.FollowersCount, x => x.FollowersCount - 1));
                }

                // 2. Xóa các quan hệ tránh lỗi FK Constraint
                _context.Follows.RemoveRange(user.FollowedFollows);
                _context.Follows.RemoveRange(user.FollowerFollows);
                _context.Albums.RemoveRange(user.Albums);

                // 3. XÓA USER → EF Core + Cascade sẽ tự động xóa:
                //    Posts, Photos, Reactions, Comments, Shares, Reports...
                _context.Users.Remove(user);
                await _context.SaveChangesAsync();

                await transaction.CommitAsync();
                return true;
            }
            catch
            {
                await transaction.RollbackAsync();
                throw;
            }
        }

        //xem tất cả report
        public async Task<List<Report>> GetAllReportsAsync()
        {
            var reports = await _context.Reports
                .ToListAsync();
            return reports;
        }

        //Xem tất cả report của 1 bài viết
        public async Task<List<Report>> GetReportByIdAsync(Guid postId)
        {
            var reports = await _context.Reports
                .Where(p => p.PostId == postId)
                .ToListAsync();
            return reports;
        }
    
        //tổng số bài viết
        public async Task<int> TotalPostAsync()
        {
            var totalPosts = await _context.Posts.CountAsync();
            return totalPosts;
        }
    }
}
